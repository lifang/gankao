#encoding: utf-8
class PagesController < ApplicationController
  require 'oauth/oauth'
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
      user_info = return_user(return_session_key(return_access_token(params[:code])))[0]
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
    consumer = OAuth::Consumer.new(app_id, app_key, CONSUMER_OPTIONS)
    request_token = consumer.get_request_token()
    session[:qqtoken] = request_token.token
    session[:qqsecret] = request_token.secret
    redirect_to request_token.authorize_url + "&oauth_consumer_key=#{app_id}&oauth_callback=http://localhost:3000/pages/qq_index"
  end


  def qq_index
    begin
      consumer = OAuth::Consumer.new(app_id, app_key, CONSUMER_OPTIONS)
      request_token = ::OAuth::RequestToken.new(consumer, session[:qqtoken], session[:qqsecret])
      access_token = request_token.get_access_token(:oauth_vericode => params[:oauth_vericode])
      response = access_token.get("/user/get_user_info?openid=#{params[:openid]}")
      return_hash = ActiveSupport::JSON.decode(response.body)
      nickname  = User.find_by_open_id(params[:openid])
      if nickname.nil?
        return_hash["nickname"]="qq用户" if return_hash["nickname"].nil?||return_hash["nickname"]==""
        @user=User.create(:code_type=>'qq',:name=>return_hash["nickname"],:username=>return_hash["nickname"],:open_id=>params[:openid])
      end
      cookies[:user_id] = @user.id
      render :inline => "<script>window.opener.location.href='/user/homes/#{Category::TYPE_IDS[:english_fourth_level]}';window.close();</script>"
    rescue
      render :inline => "<script>window.opener.location.reload();window.close();</script>"
    end
  end

end