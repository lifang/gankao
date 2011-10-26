#encoding: utf-8
class User::AlipaysController < ApplicationController
  include User::AlipaysHelper
  @@m = Mutex.new


  
  def alipay_request
    out_trade_no="#{cookies[:user_id]}_#{Time.now.strftime("%Y%m%d%H%M%S")}#{Time.now.to_i}"
    OPTIONS.merge!(:seller_email =>SELLER_EMAIL, :partner =>PARTNER, :_input_charset => 'utf-8',:out_trade_no=>out_trade_no)
    OPTIONS.merge!(:sign_type => 'MD5', :sign =>Digest::MD5.hexdigest(OPTIONS.sort.map{|k,v|"#{k}=#{v}"}.join("&")+PARTNER_KEY))
    redirect_to "#{PAGE_WAY}?#{OPTIONS.sort.map{|k, v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"}.join('&')}"
  end


  def take_over_return
    out_trade_no=params[:out_trade_no]
    order_exist=Order.first("out_trade_no=#{out_trade_no}")
    unless order_exist.nil?
      alipay_notify_url = "http://notify.alipay.com/trade/notify_query.do?partner=#{PARTNER}&notify_id=#{params[:notify_id]}"
      puts alipay_notify_url
      response_txt =Net::HTTP.get(URI.parse(alipay_notify_url))
      puts response_txt
      my_params = Hash.new
      request.parameters.each {|key,value|my_params[key.to_s]=value}
      my_params["action"]=""
      my_params["controller"]=""
      my_params["sign"]=""
      my_params["sign_type"]=""
      mysign = Digest::MD5.hexdigest(my_params.sort.map{|k,v|"#{k}=#{v}"}.join("&")+PARTNER_KEY)
      puts  mysign
      puts request.parameters
      file_path = "#{Rails.root}/log/apliay/#{Time.now.strftime("%Y%m%d")}.log"
      if File.exists? file_path
        file = File.open( file_path,"a")
      else
        file = File.new( file_path,"w")
      end
      file.puts Time.now.strftime("%Y%m%d %H:%M:%S")+"  "+request.parameters.to_s+"\r\n"
      if mysign==params[:sign] and response_txt=="true"
        if params[:trade_status]=="WAIT_BUYER_PAY"
          render :text=>"success"
        elsif params[:trade_status]=="TRADE_FINISHED" or params[:trade_status]=="TRADE_SUCCESS"
          puts out_trade_no
          puts params
          puts "trade_status success"
          @@m.synchronize {
            trade_nu =out_trade_no.to_s.split("_")
            begin
              puts trade_nu[0]
              puts trade_nu[1]
              Order.transaction do
                Order.create(:user_id=>trade_nu[0],:types=>Order::TYPES[:english_fourth_level],:remark=>"支付宝充值",:total_price=>Constant::VIP_FEE,:out_trade_no=>out_trade_no)
              end
              puts "render success"
              render :text=>"success"
            rescue
              puts "flash fail"
              render :text=>"success"
            end
          }
        else
          render :text=>"fail" + "<br>"
          puts mysign + "-----------"+ params[:sign] + "<br>"
        end
      else
        redirect_to "/users/get_vip"
      end
    else
      redirect_to "/users/get_vip"
    end
  end

end