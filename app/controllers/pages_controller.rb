class PagesController < ApplicationController
require 'uri/https'
  def index
    
  end

  def sina_index
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    oauth.authorize_from_request(session[:rtoken],session[:rsecret], params[:oauth_verifier])
    session[:rtoken], session[:rsecret] = nil, nil
    session[:atoken], session[:asecret] = oauth.access_token.token, oauth.access_token.secret
    user_info = Weibo::Base.new(oauth).verify_credentials
    @user=User.where("code_id=#{user_info[:id]} and code_type='sina'").first
    if @user==nil
      @user=User.create(:code_id=>user_info[:id],:code_type=>'sina',:name=>user_info[:name],:username=>user_info[:name])
    end
    cookies[:user_name] = user_info[:name]
    cookies[:user_id]=@user.id
    render :inline => "<script>window.opener.refresh();window.close();</script>"

  end
  
  def renren_index
    
    client = OAuth2::Client.new(Constant::RENREN_API_KEY,Constant::RENREN_API_SECRET,
      :site => {:url=>'https://graph.renren.com',:response_type=>'code'}, :access_token_url =>"https://graph.renren.com/oauth/token")
    access_token = client.web_server.get_access_token(params[:code], {:redirect_uri => "http://localhost:3000/pages/renren_index"})
    session[:renren_access_token]=access_token
    #到了这里已经得到了access_token，我暂时把它存在session里面，方便以后使用
   # puts URI::HTTPS.PA URI.encode("https://graph.renren.com/renren_api/session_key?oauth_token=#{session[:renren_access_token]}")
    geturi=URI.parse(URI.encode("https://graph.renren.com/renren_api/session_key?oauth_token=#{session[:renren_access_token]}"))#获得Session Key,为调用renren api做准备
    res=JSON Net::HTTP.get(geturi)#这里我们就得到了人人 api
    session[:renren_session_key]= res["renren_token"]["session_key"]
    session[:renren_expires_in]=res["renren_token"]["expires_in"]
    session[:renren_refresh_token]=res["renren_token"]["refresh_token"]

    query={:api_key=>Constant::RENREN_API_KEY,
      :format=>'JSON',
      :method=>'users.getInfo',
      :session_key=>session[:renren_session_key],
      :v=>'1.0'
    }#按照api组织参数
    
    @user=JSON Net::HTTP.post_form(URI.parse(URI.encode("http://api.renren.com/restserver.do")),query).body
   # render :inline => "<script>window.opener.refresh();window.close();</script>"
    render 'index'
  end


end