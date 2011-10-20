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
    url="#{REQUEST_URL}?#{PARAMS}&oauth_signature=#{signature_params(app_key,PARAMS,REQUEST_URL)}"
    puts url
    request_token=OAuth2::Client.new(app_id, app_key,{}).request(:get, url,{},{})
    puts request_token
    redirect_to "#{AUTHOTIZE_URL}?oauth_consumer_key=223448&oauth_token=#{request_token.split("=")[1].split("&")[0]}&oauth_callback=#{CALLBACK_URL}"
  end


  def qq_index
    #    begin
    url="#{GRAPY_URL}?access_token=#{params[:oauth_token]}&openid=#{params[:openid]}&#{PARAMS}&format=json&oauth_signature=#{signature_params(app_key,PARAMS,GRAPY_URL)} "
    request_token=JSON OAuth2::Client.new(app_id, app_key,{}).request(:get, url,{},{})
    @user= User.find_by_open_id(params[:openid])
    if @user.nil?
      request_token["nickname"]="qq用户" if request_token["nickname"].nil?||request_token["nickname"]==""
#      @user=User.create(:code_type=>'qq',:name=>request_token["nickname"],:username=>request_token["nickname"],:open_id=>params[:openid])
    end
    cookies[:user_id] = @user.id
    render :inline => "<script>window.opener.location.href='/user/homes/#{Category::TYPE_IDS[:english_fourth_level]}?url=#{url}&request=#{request_token}';window.close();</script>"
    #    rescue
    #      render :inline => "<script>window.opener.location.reload();window.close();</script>"
    #    end
  end

  



end