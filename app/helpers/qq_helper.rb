module QqHelper
  require 'oauth2'
  require 'oauth'

  #qq登录参数
  GRAPY_URL="http://openapi.qzone.qq.com/user/get_user_info"
  REQUEST_URL="http://openapi.qzone.qq.com/oauth/qzoneoauth_request_token"
  AUTHOTIZE_URL="http://openapi.qzone.qq.com/oauth/qzoneoauth_authorize"
  CALLBACK_URL="http://demo.gankao.co/pages/qq_index"
  QQ_ACCESS_URL="http://openapi.qzone.qq.com/oauth/qzoneoauth_access_token"
 

  #腾讯微博登录参数:
  REQUEST_WEIBO="https://open.t.qq.com/cgi-bin/request_token"
  ADD_FRIEND="http://open.t.qq.com/api/friends/add"
  ACCESS_TOKEN_URL="http://open.t.qq.com/cgi-bin/access_token"
  FRIEND_URL="http://open.t.qq.com/api"
  ADD_WEIBO="http://open.t.qq.com/api/t/add"
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


  
  #qq登录
  def app_id
    100224552
  end

  def app_key
    "748a38039061788ba974ecb47538815a"
  end
  


  #腾讯微博
  def weibo_app_key
    801004949
  end

  def weibo_app_secret
    "b5ab55615ee5261fcadf2f50128edb51"
  end


  #公共方法加密url及生成签名：
  def signature_params(key,sign,url,method,secret)
    signature="#{method}&#{url_encoding(url)}&#{url_encoding(sign)}"
    return url_encoding(Base64.encode64(OpenSSL::HMAC.digest("sha1","#{key}&#{secret}",signature)))
  end

  def url_encoding(str)
    str.gsub("=", "%3D").gsub("/","%2F").gsub(":","%3A").gsub("&","%26").gsub("+","%2B")
  end




 



end
