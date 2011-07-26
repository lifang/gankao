
module RenrenHelper

  require 'oauth2'
  require 'net/http'

  def client

    OAuth2::Client.new(api_key,

      api_secret,

      :site => {

        :url=>'https://graph.renren.com',

        :response_type=>'code'})

  end
  #第一步：获取Authorization Code



  def login

    redirect_to client.web_server.authorize_url(

      :redirect_uri => "http://localhost:3000/renren/loginnext",

      :response_type=>'code'

    )

  end
  #第二步：使用Authorization Code换取Access Token

  def loginnext

    access_token = client.web_server.get_access_token(params[:code], {:redirect_uri => "http://localhost:3000/renren/loginnext"})

    session[:renren_access_token]=access_token

    #到了这里已经得到了access_token，我暂时把它存在session里面，方便以后使用

    geturi=URI.parse(URI.encode("http://graph.renren.com/renren_api/session_key?oauth_token=#{session[:renren_access_token]}"))#获得Session Key,为调用renren api做准备

    res=JSON Net::HTTP.get(geturi)#这里我们就得到了人人 api

    session[:renren_session_key]= res["renren_token"]["session_key"]

    session[:renren_expires_in]=res["renren_token"]["expires_in"]

    session[:renren_refresh_token]=res["renren_token"]["refresh_token"]

    redirect_to "/pages"#定向到我们的应用页面

  end



  def user

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


  def redirect_uri

    uri = URI.parse(request.url)

    uri.path = '/pages/renren_index'

    uri.query = nil

    uri.to_s

  end

  def api_key

    "7f4d7bacf5b144d8940d5a8177b592b0"

  end

  def api_secret
    "a1f075b9646b4354808f357623e8bac5"
  end


end
