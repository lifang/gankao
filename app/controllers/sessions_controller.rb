#encoding: utf-8
class SessionsController < ApplicationController
  layout "login"
  require 'oauth2'
  require 'oauth'
  #  require  'net/http'
  include QqHelper

  def new
    session[:signin_code] = proof_code(4)
  end
  
  def create
    @user = User.find_by_email(params[:session][:email])
    if @user.nil?
      flash[:error] = "用户不存在"
    elsif !@user.has_password?(params[:session][:password])
      flash[:error] = "密码输入有误"
    elsif @user.status == User::STATUS[:LOCK]
      flash[:error] = "您的账号还未验证，请先去您的注册邮箱进行验证"
    else
      delete_cookies
      cookies[:user_id] = @user.id
      cookies[:user_name] = @user.name
      cookie_role(cookies[:user_id])
      is_vip?   
    end
    if flash[:error]
      redirect_to request.referer
    else
      if params[:session][:is_auto_login]=="1"
        cookies[:is_auto_login] = {:value => @user.id, :expires => Time.now+30.days, :path => "/", :secure => false}
      end
      redirect_to "/user/homes/#{Category::TYPE_IDS[:english_fourth_level]}"
    end
  end

  #退出登录
  def destroy
    delete_cookies
    redirect_to root_path
  end

  def delete_cookies
    cookies.delete(:user_id)
    cookies.delete(:user_name)
    cookies.delete(:user_roles)
    cookies.delete(:is_vip)
    cookies.delete(:is_auto_login)
    session.delete(:atoken)
    session.delete(:asecret)
    session.delete(:renren_access_token)
    session.delete(:renren_session_key)
    session.delete(:renren_session_secret)
    session.delete(:renren_expires_in)
  end

  #获取更改密码的邮件
  def user_code
    user=User.find_by_email(params[:anonymous])
    if user
      UserMailer.update_code(user).deliver
      redirect_to "/sessions/#{user.id}/active"
    else
      flash[:error]="密码有误，请重新输入"
      render "/sessions/get_code"
    end
  end

  #填写密码界面
  def new_code
    @user=User.find(params[:id])
  end

  #更新密码
  def update_user_code
    user=User.find(params[:id])
    user.update_attributes(:password=>params[:session][:password])
    user.encrypt_password
    user.save
    flash[:success]="密码更新成功"
    redirect_to "/sessions/new"
  end

  #收取邮件并登录
  def active
    @user = User.find(params[:id].to_i)
  end

  def sina_login
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    request_token = oauth.consumer.get_request_token
    session[:rtoken], session[:rsecret] = request_token.token, request_token.secret
    redirect_to "#{request_token.authorize_url}&oauth_callback=http://#{request.env["HTTP_HOST"]}/pages/sina_index"
  end

  def renren_login
    redirect_to client.web_server.authorize_url(:redirect_uri => RenrenHelper::CALL_BACK_URL, :response_type=>'code')
  end

  def friend_add_request
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    request_token = oauth.consumer.get_request_token
    session[:rtoken], session[:rsecret] = request_token.token, request_token.secret
    redirect_to "#{request_token.authorize_url}&oauth_callback=http://#{request.env["HTTP_HOST"]}/sessions/friend_add"
  end

  def friend_add
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    oauth.authorize_from_request(session[:rtoken],session[:rsecret], params[:oauth_verifier])
    session[:rtoken], session[:rsecret] = nil, nil
    unless  Weibo::Base.new(oauth).friendship_show({:target_id=>Constant::WEIBO_ID})[:source][:following]
      Weibo::Base.new(oauth).friendship_create(Constant::WEIBO_ID, follow=false)
      flash[:warn]="添加关注成功"
    else
      flash[:warn]="已添加关注"
    end
    render :inline => " <link href='/stylesheets/style.css' rel='stylesheet' type='text/css' />
    <script type='text/javascript' src='/javascripts/jquery-1.5.2.js'></script>
    <script type='text/javascript' src='/javascripts/TestPaper.js'></script><div id='flash_notice' class='tishi_tab'><p><%= flash[:warn] %></p></div>
    <script type='text/javascript'>show_flash_div();</script><script> setTimeout(function(){
      window.close();}, 2000)</script>"
  end

  #腾讯微博登录
  def qq_weibo
    consumer = OAuth::Consumer.new(weibo_app_key, weibo_app_secret, OPTIONS)
    request_token = consumer.get_request_token(:oauth_callback => "http://localhost:3000/sessions/access_token")
    session[:token]=request_token
    session[:qqtoken] = request_token.token
    puts session[:qqtoken]
    session[:qqsecret] = request_token.secret
    redirect_to request_token.authorize_url
  end

  def access_token
    timestamp=(Time.new.to_i).to_s
    #    consumer = OAuth::Consumer.new(weibo_app_key, weibo_app_secret,OPTIONS)
    #    access_token=consumer.get_access_token(session[:token],{:oauth_verifier=>params[:oauth_verifier]},{},{})
    oauth_token=params[:oauth_token]
    params="name=gankao2011&oauth_consumer_key=801003611&oauth_nonce=#{timestamp}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=#{timestamp}&oauth_token=#{oauth_token}&oauth_version=1.0"
    url="#{ACCESS_TOKEN_URL}?#{params}&oauth_signature=#{signature_params(weibo_app_secret,params,ACCESS_TOKEN_URL,"GET")}"
    access_token=OAuth2::Client.new(weibo_app_key, weibo_app_secret,{}).request(:get, url,{},{})
    puts  access_token
    #    puts url
    #    redirect_to url
  end

  def qq_add_friend
    puts params[:oauth_token]
    redirect_to "https://open.t.qq.com/cgi-bin/access_token?oauth_token=#{params[:oauth_token]}"
  end


end

