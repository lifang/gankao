#encoding: utf-8
class CompetesController < ApplicationController
  layout "compete"
  before_filter :access? , :only => [:alipay_request]
  include User::AlipaysHelper
  include RenrenHelper
  @@m = Mutex.new


  def renren_exercise
    redirect_to client.web_server.authorize_url(:redirect_uri =>RenrenHelper::CALLBACK_URL, :response_type=>'code')
  end

  def renren_compete
    #    begin
    session_key = return_session_key(get_access_token(params[:code]))
    user_info = return_user(session_key)[0]
    @user=User.where("code_id=#{user_info["uid"].to_s} and code_type='renren'").first
    if @user.nil?
      @user=User.create(:code_id=>user_info["uid"],:code_type=>'renren',:name=>user_info["name"],:username=>user_info["name"])
    end
    cookies[:user_name] ={:value =>@user.name, :path => "/", :secure  => false}
    cookies[:user_id] ={:value =>@user.id, :path => "/", :secure  => false}
    render :inline => "<script>window.opener.location.reload();window.close();</script>"
    #    rescue
    #      render :inline => "<script>window.opener.location.reload();window.close();</script>"
    #    end
  end

  def alipay_exercise
    options ={
      :service=>"create_direct_pay_by_user",
      :notify_url=>"http://demo.gankao.co/competes/alipay_compete",
      :subject=>"2011大学英语四级模拟考试",
      :payment_type=>Constant::VIP_TYPE[:good],
      :total_fee=>Constant::SIMULATION_FEE
    }
    out_trade_no="#{cookies[:user_id]}_#{Time.now.strftime("%Y%m%d%H%M%S")}#{Time.now.to_i}"
    options.merge!(:seller_email =>User::AlipaysHelper::SELLER_EMAIL, :partner =>User::AlipaysHelper::PARTNER, :_input_charset=>"utf-8", :out_trade_no=>out_trade_no)
    options.merge!(:sign_type => "MD5", :sign =>Digest::MD5.hexdigest(options.sort.map{|k,v|"#{k}=#{v}"}.join("&")+User::AlipaysHelper::PARTNER_KEY))
    redirect_to "#{User::AlipaysHelper::PAGE_WAY}?#{options.sort.map{|k, v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"}.join('&')}"
  end


  def alipay_compete
    out_trade_no=params[:out_trade_no]
    trade_nu =out_trade_no.to_s.split("_")
    order=Compete.find(:first, :conditions => ["user_id=?",trade_nu[0]])
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
      dir = "#{Rails.root}/public/compete"
      Dir.mkdir(dir)  unless File.directory?(dir)
      file_path = dir+"/#{Time.now.strftime("%Y%m%d")}.log"
      if File.exists? file_path
        file = File.open( file_path,"a")
      else
        file = File.new(file_path, "w")
      end
      file.puts "#{Time.now.strftime('%Y%m%d %H:%M:%S')}   #{request.parameters.to_s}\r\n"
      file.close
      if mysign==params[:sign] and response_txt=="true"
        if params[:trade_status]=="WAIT_BUYER_PAY"
          render :text=>"success"
        elsif params[:trade_status]=="TRADE_FINISHED" or params[:trade_status]=="TRADE_SUCCESS"
          @@m.synchronize {          
            begin
              Compete.transaction do
                Compete.create(:user_id => trade_nu[0], :remark => "支付宝充值",:price =>Constant::VIP_FEE)
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



  

end
