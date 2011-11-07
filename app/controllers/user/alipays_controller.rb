#encoding: utf-8
class User::AlipaysController < ApplicationController
  before_filter :access? , :only => [:alipay_request]
  include User::AlipaysHelper
  @@m = Mutex.new
  
  def alipay_request
    is_vip_user=Order.find_by_user_id(cookies[:user_id])
    if is_vip_user.nil?
      out_trade_no="#{cookies[:user_id]}_#{Time.now.strftime("%Y%m%d%H%M%S")}#{Time.now.to_i}"
      OPTIONS.merge!(:seller_email =>User::AlipaysHelper::SELLER_EMAIL, :partner =>User::AlipaysHelper::PARTNER, :_input_charset =>"utf8",:out_trade_no=>out_trade_no)
      puts OPTIONS.sort.map{|k,v|"#{k}=#{v}"}.join("&")+User::AlipaysHelper::PARTNER_KEY
      OPTIONS.merge!(:sign_type => "MD5", :sign =>Digest::MD5.hexdigest(OPTIONS.sort.map{|k,v|"#{k}=#{v}"}.join("&")+User::AlipaysHelper::PARTNER_KEY))
      redirect_to "#{User::AlipaysHelper::PAGE_WAY}?#{OPTIONS.sort.map{|k, v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"}.join('&')}"
    else
      flash[:warn]="您已经是vip用户"
      render :inline => " <link href='/stylesheets/style.css' rel='stylesheet' type='text/css' />
    <script type='text/javascript' src='/javascripts/jquery-1.5.2.js'></script>
    <script type='text/javascript' src='/javascripts/TestPaper.js'></script><div id='flash_notice' class='tishi_tab'><p><%= flash[:warn] %></p></div>
    <script type='text/javascript'>show_flash_div();</script><script> setTimeout(function(){
      window.close();}, 2000)</script><% flash[:warn]=nil %>"
    end
  end


  def take_over_return
    out_trade_no=params[:out_trade_no]
    order=Order.find(:first, :conditions => ["out_trade_no=?",out_trade_no])
    if order.nil?
      alipay_notify_url = "#{User::AlipaysHelper::NOTIFY_URL}?partner=#{User::AlipaysHelper::PARTNER}&notify_id=#{params[:notify_id]}"
      response_txt =Net::HTTP.get(URI.parse(alipay_notify_url))
      my_params = Hash.new
      request.parameters.each {|key,value|my_params[key.to_s]=value}
      my_params.delete("action")
      my_params.delete("controller")
      my_params.delete("sign")
      my_params.delete("sign_type")
      mysign = Digest::MD5.hexdigest(my_params.sort.map{|k,v|"#{k}=#{v}"}.join("&")+User::AlipaysHelper::PARTNER_KEY)
      dir = "#{Rails.root}/public/apliay"
      Dir.mkdir(dir)  unless File.directory?(dir)
      file_path = dir+"/#{Time.now.strftime("%Y%m%d")}.log"
      if File.exists? file_path
        file = File.open( file_path,"a")
      else
        file = File.new( file_path,"w+")
      end
      file.puts "#{Time.now.strftime('%Y%m%d %H:%M:%S')}   #{request.parameters.to_s}\r\n"
      file.close
      if mysign==params[:sign] and response_txt=="true"
        if params[:trade_status]=="WAIT_BUYER_PAY"
          render :text=>"success"
        elsif params[:trade_status]=="TRADE_FINISHED" or params[:trade_status]=="TRADE_SUCCESS"
          @@m.synchronize {
            trade_nu =out_trade_no.to_s.split("_")
            begin
              Order.transaction do
                Order.create(:user_id => trade_nu[0], :types => Order::TYPES[:english_fourth_level], :remark => "支付宝充值",
                  :total_price => Constant::VIP_FEE, :out_trade_no => out_trade_no,
                  :status => Order::STATUS[:payed], :pay_type => Order::PAY_TYPE[:PAYMENT])
              end
              render :text=>"success"
            rescue
              render :text=>"success"
            end
          }
        else
          render :text=>"fail" + "<br>"
        end
      else
        redirect_to "/users/get_vip"
      end
    else
      render :text=>"success"
    end
  end

  def over_pay
    out_trade_no=params[:out_trade_no]
    order=Order.find(:first, :conditions => ["out_trade_no=?",out_trade_no])
    if order.nil?
      flash[:warn]="充值不成功"
    else
      flash[:warn]="充值成功，恭喜您成为vip"
    end
    render :inline => " <link href='/stylesheets/style.css' rel='stylesheet' type='text/css' />
    <script type='text/javascript' src='/javascripts/jquery-1.5.2.js'></script>
    <script type='text/javascript' src='/javascripts/TestPaper.js'></script><div id='flash_notice' class='tishi_tab'><p><%= flash[:warn] %></p></div>
    <script type='text/javascript'>show_flash_div();</script><script> setTimeout(function(){
      window.close();}, 1000)</script><% flash[:warn]=nil %>"
  end




end