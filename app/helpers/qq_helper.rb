module QqHelper
  require 'oauth2'
  require 'oauth'

  #qq登录
  GRAPY_URL="http://graph.qq.com/user/get_user_info"
  REQUEST_URL="http://openapi.qzone.qq.com"
  OAUTH_CON=(Time.new.to_i + 100).to_s
  OAUTH_TIMESTAMP=(Time.new.to_i).to_s
  PARAMS="oauth_client_ip=116.255.140.79&oauth_consumer_key=223448&oauth_nonce=#{OAUTH_CON}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=#{OAUTH_TIMESTAMP}&oauth_version=1.0"

 
  HTTP_URL="https://open.t.qq.com"
  OPTIONS={
    :site =>HTTP_URL ,
    :request_token_path => "/cgi-bin/request_token",
    :access_token_path => "/cgi-bin/access_token",
    :authorize_path => "/cgi-bin/authorize",
    :oauth_callback=>"#{Constant::SERVER_PATH}/sessions/qq_add_friend",
    :http_method => :get,
    :scheme => :query_string,
    :nonce => Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32],
    :realm =>"#{Constant::SERVER_PATH}/sessions/qq_add_friend",
  }


  
  #qq登录
  def app_id
    223448
  end

  def app_key
    "64d7ddfe7e483dd51b2b14cf2ec0ec27"
  end

  
  
  def signature_params
    signature="GET&http%3A%2F%2Fopenapi.qzone.qq.com%2Foauth%2Fqzoneoauth_request_token&#{url_encoding(PARAMS)}"
    return url_encoding(Base64.encode64(OpenSSL::HMAC.digest("sha1","64d7ddfe7e483dd51b2b14cf2ec0ec27&",signature)))
  end

  def url_encoding(str)
    str.gsub("=", "%3D").gsub("/","%2F").gsub(":","%3A").gsub("&","%26")
  end
  
  #腾讯微博

  def weibo_app_key
    801003611
  end

  def weibo_app_secret
    "40ee1e5183af2fbef676cc273d220da4"
  end



end
