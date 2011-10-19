module QqHelper
  require 'oauth2'
  require 'oauth'

  #qq登录参数
  GRAPY_URL="http://openapi.qzone.qq.com/user/get_user_info"
  REQUEST_URL="http://openapi.qzone.qq.com/oauth/qzoneoauth_request_token"
  AUTHOTIZE_URL="http://openapi.qzone.qq.com/oauth/qzoneoauth_authorize"
  CALLBACK_URL="http://www.gankao.co/pages/qq_index"
  OAUTH_CON=(Time.new.to_i + 100).to_s
  OAUTH_TIMESTAMP=(Time.new.to_i).to_s
  PARAMS="oauth_client_ip=116.255.140.79&oauth_consumer_key=223448&oauth_nonce=#{OAUTH_CON}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=#{OAUTH_TIMESTAMP}&oauth_version=1.0"

  #腾讯微博登录参数：
  WEIBO_URL="https://open.t.qq.com/cgi-bin/request_token"
  OPTIONS="oauth_callback=http://localhost:3000&oauth_consumer_key=801003611&oauth_nonce=#{OAUTH_CON}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=#{OAUTH_TIMESTAMP}&oauth_version=1.0"
  WEIBO_AUTHORIZE="https://open.t.qq.com/cgi-bin/authorize"
  ADD_FRIEND="http://open.t.qq.com/api/friends/add"
  ACCESS_TOKEN_URL="https://open.t.qq.com/cgi-bin/access_token"

  
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
  def signature_params(key,sign,url)
    signature="GET&#{url_encoding(url)}&#{url_encoding(sign)}"
    return url_encoding(Base64.encode64(OpenSSL::HMAC.digest("sha1","#{key}&",signature)))
  end

  def url_encoding(str)
    str.gsub("=", "%3D").gsub("/","%2F").gsub(":","%3A").gsub("&","%26").gsub("+","%2B")
  end




 



end
