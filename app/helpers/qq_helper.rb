module QqHelper
  require 'oauth2'
  require 'oauth'
  #qq登录
  CONSUMER_OPTIONS = {
    :site => "http://openapi.qzone.qq.com",
    :request_token_path => "/oauth/qzoneoauth_request_token",
    :access_token_path => "/oauth/qzoneoauth_access_token",
    :authorize_path => "/oauth/qzoneoauth_authorize",
    :http_method => :get,
    :scheme => :query_string,
    :nonce => Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32] }



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

  


end
