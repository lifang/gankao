#encoding: utf-8
class PagesController < ApplicationController
  require 'oauth/oauth'
  include QqHelper
  def index
    if cookies[:user_id] and request.referer == "/"
      redirect_to "/user/homes/#{Category::TYPE_IDS[:english_fourth_level]}"
    else
      @title="赶考"
      render :layout=>"index"
    end
  end

  def sina_index
    begin
      oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
      oauth.authorize_from_request(session[:rtoken],session[:rsecret], params[:oauth_verifier])
      session[:rtoken], session[:rsecret] = nil, nil
      session[:atoken], session[:asecret] = oauth.access_token.token, oauth.access_token.secret
      user_info = Weibo::Base.new(oauth).verify_credentials
      @user=User.where("code_id=#{user_info[:id].to_s} and code_type='sina'").first
      if @user.nil?
        @user=User.create(:code_id=>user_info[:id],:code_type=>'sina',:name=>user_info[:name],:username=>user_info[:name])
      end
      cookies[:user_name] = user_info[:name]
      cookies[:user_id]=@user.id
      render :inline => "<script>window.opener.location.href='/user/homes/#{Category::TYPE_IDS[:english_fourth_level]}';window.close();</script>"
    rescue
      render :inline => "<script>window.opener.location.reload();window.close();</script>"
    end
  end

  
  def renren_index
    begin
      session_key = return_session_key(return_access_token(params[:code]))
      user_info = return_user(session_key)[0]
   
      @user=User.where("code_id=#{user_info["uid"].to_s} and code_type='renren'").first
      if @user.nil?
        @user=User.create(:code_id=>user_info["uid"],:code_type=>'renren',:name=>user_info["name"],:username=>user_info["name"])
      end
      cookies[:user_name] = @user.name
      cookies[:user_id] = @user.id
      cookies.each do |key,value|
        puts key.to_s+"   "+value.to_s
      end
      session.each do |key,value|
        puts key.to_s+"   "+value.to_s
      end
      render :inline => "<script>window.opener.location.href='/user/homes/#{Category::TYPE_IDS[:english_fourth_level]}';window.close();</script>"
    rescue
      render :inline => "<script>window.opener.location.reload();window.close();</script>"
    end
  end
  

  def login_from_qq
      url= produce_url(REQUEST_URL,login_qq_params,"")
      request_token=Net::HTTP.get(URI.parse(url))
      request_value=request_token.split("=")
      session[:secret]=request_value[2]
      redirect_to "#{AUTHOTIZE_URL}?#{COMSUMER_KEY}&oauth_token=#{request_value[1].split("&")[0]}&oauth_callback=#{CALLBACK_URL}"
  end

  def qq_index 
    oauth_token=params[:oauth_token]
    oauth_vericode=params[:oauth_vericode]
    begin   
      url= produce_url(QQ_ACCESS_URL,access_url_params(oauth_token,oauth_vericode),session[:secret])
      access=Net::HTTP.get(URI.parse(url))
      session[:secret]=nil
      session[:qqtoken]=access.split("oauth_token=")[1].split("&")[0]
      session[:qqsecret]=access.split("oauth_token_secret=")[1].split("&")[0]
      session[:qqopen_id]=access.split("openid=")[1].split("&")[0]
      user_url= produce_url(GRAPY_URL,get_user_info_params(session[:qqtoken],session[:qqopen_id]),session[:qqsecret])
      user_info=JSON Net::HTTP.get(URI.parse(user_url))
      @user= User.find_by_open_id(session[:qqopen_id])
      if @user.nil?
        user_info["nickname"]="qq用户" if user_info["nickname"].nil?||user_info["nickname"]==""
        @user=User.create(:code_type=>'qq',:name=>user_info["nickname"],:username=>user_info["nickname"],:open_id=>session[:qqopen_id])
      end
      session[:qqtoken]=nil
      session[:qqsecret]=nil
      session[:qqopen_id]=nil
      cookies[:user_id] = @user.id
      render :inline => "<script>window.opener.location.href='/user/homes/#{Category::TYPE_IDS[:english_fourth_level]}';window.close();</script>"
    rescue
      render :inline => "<script>window.opener.location.reload();window.close();</script>"
    end
  end



end