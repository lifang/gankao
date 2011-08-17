
module RenrenHelper

  require 'oauth2'
  require 'net/http'

  def rr_client
    OAuth2::Client.new(api_key,api_secret,
      :site => {
        :url=>'https://graph.renren.com',
        :response_type=>'code'})
  end 
  #第一步：获取Authorization Code

  def rr_login(redirect_url)
    redirect_to rr_client.web_server.authorize_url(
      :redirect_uri => redirect_url,
      :response_type=>'code'
    )
  end
  #第二步：使用Authorization Code换取Access Token

  def rr_connect
    http = Net::HTTP.new('graph.renren.com', 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.get("/oauth/token?grant_type=authorization_code&code=#{params[:code]}&client_id=7f4d7bacf5b144d8940d5a8177b592b0&client_secret=fe0430b144ff4cb48f1060933e1f68b0&redirect_uri=http://localhost:3000/pages/renren_index")
    json_res=JSON res.body
    puts "==============================================="
    puts res.body
    puts "==============================================="
    puts json_res
    puts "==============================================="
    session[:renren_access_token]=json_res["access_token"]
    #到了这里已经得到了access_token，我暂时把它存在session里面，方便以后使用

    http = Net::HTTP.new('graph.renren.com', 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    path = URI.encode("/renren_api/session_key?oauth_token=#{session[:renren_access_token]}".gsub("\"",""))
    session_res=http.get(path)
    json_session=JSON session_res.body
    session[:renren_session_key]=json_session["renren_token"]["session_key"]
    session[:renren_session_secret]=json_session["renren_token"]["session_secret"]
    session[:renren_expires_in]=json_session["renren_token"][ "expires_in"]
    #到了这里已经得到了session_key，我暂时把它存在session里面，方便以后使用

  end
 #连接人人，取得access_token,以及session_key。凭此取得人人API数据


  def rr_user_info
    session_key=session[:renren_session_key]
    str="api_key=#{api_key}"
    str<<"call_id=#{Time.now.to_i}"
    str<<"format=JSON"
    str<<"method=xiaonei.users.getInfo"
    str<<"session_key=#{session_key}"
    str<<"v=1.0"
    str<<"#{api_secret}"#注意这里的str是有顺序的，具体的要求请参考［4］
    sig=Digest::MD5.hexdigest(str)#生成参数sig（这是个什么东东呢，人人的解释是“ 它是由当前请求参数和secretKey的一个MD5值”）
    
    query={:api_key=>api_key,
      :call_id=>Time.now.to_i,
      :format=>'JSON',
      :method=>'xiaonei.users.getInfo',
      :session_key=>session_key,
      :v=>'1.0',
      :sig=>sig
    }#按照api组织参数

    @user=JSON Net::HTTP.post_form(URI.parse(URI.encode("http://api.renren.com/restserver.do")),
      query).body 
    #请求数据并且转换成json数据
  end
 #取得用户的信息

  def api_key
    "7f4d7bacf5b144d8940d5a8177b592b0"
  end

  def api_secret
    "fe0430b144ff4cb48f1060933e1f68b0"
  end

end
