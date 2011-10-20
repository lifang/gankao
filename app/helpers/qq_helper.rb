module QqHelper
  require 'oauth2'
  require 'oauth'

  #qq登录参数
  GRAPY_URL="http://openapi.qzone.qq.com/user/get_user_info"
  REQUEST_URL="http://openapi.qzone.qq.com/oauth/qzoneoauth_request_token"
  AUTHOTIZE_URL="http://openapi.qzone.qq.com/oauth/qzoneoauth_authorize"
  CALLBACK_URL="http://www.gankao.co/pages/qq_index"
 

  #腾讯微博登录参数:
  #  WEIBO="open.t.qq.com"
  #  REQUEST_WEIBO="https://open.t.qq.com/cgi-bin/request_token"
  #  WEIBO_URL="/cgi-bin/request_token"
  #  OPTIONS="oauth_callback=localhost:3000&oauth_consumer_key=801003611&oauth_nonce=#{OAUTH_CON}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=#{OAUTH_TIMESTAMP}&oauth_version=1.0"
  #  WEIBO_AUTHORIZE="https://open.t.qq.com/cgi-bin/authorize"
  #  ADD_FRIEND="http://open.t.qq.com/api/friends/add"


 ACCESS_TOKEN_URL="http://open.t.qq.com/cgi-bin/access_token"
  FRIEND_URL="http://open.t.qq.com/api"
  ADD_URL="http://open.t.qq.com/api/friends/add"

  OPTIONS={
    :site               => "https://open.t.qq.com",
    :scheme             => :query_string,
    :http_method        => :get,
    :signature_method => "HMAC-SHA1",
    :oauth_callback => "http://localhost:3000",
    :request_token_path => "/cgi-bin/request_token",
    :access_token_path  => "/cgi-bin/access_token",
    :authorize_path     => "/cgi-bin/authorize",
    :nonce => Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32]
  }

  #  ADD_FRIEND={
  #    :name=>"gankao2011",
  #    :oauth_consumer_key=>801003611,
  #    :oauth_nonce=>OAUTH_CON,
  #    :oauth_signature_method=>"HMAC-SHA1",
  #    :oauth_timestamp=>OAUTH_CON,
  #    :oauth_version=>"1.0"
  #  }


  
  #qq登录
  def app_id
    223448
  end

  def app_key
    "64d7ddfe7e483dd51b2b14cf2ec0ec27"
  end
  


  #腾讯微博
  def weibo_app_key
    801003611
  end

  def weibo_app_secret
    "40ee1e5183af2fbef676cc273d220da4"
  end


  #公共方法加密url及生成签名：
  def signature_params(key,sign,url,method)
    signature="#{method}&#{url_encoding(url)}&#{url_encoding(sign)}"
    return url_encoding(Base64.encode64(OpenSSL::HMAC.digest("sha1","#{key}&",signature)))
  end

  def url_encoding(str)
    str.gsub("=", "%3D").gsub("/","%2F").gsub(":","%3A").gsub("&","%26").gsub("+","%2B")
  end




 



end
