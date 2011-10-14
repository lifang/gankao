module QqHelper
  require 'oauth2'
  require 'oauth'
  OAUTH_CON=(Time.new.to_i + 100).to_s
  OAUTH_TIMESTAMP=(Time.new.to_i + 100).to_s
  HTT_URL="http://openapi.qzone.qq.com/oauth/qzoneoauth_request_token"
  CONSUMER_OPTIONS = {
      :site => "http://openapi.qzone.qq.com",
      :request_token_path => "/oauth/qzoneoauth_request_token",
      :access_token_path => "/oauth/qzoneoauth_access_token",
      :authorize_path => "/oauth/qzoneoauth_authorize",
      :http_method => :get,
      :scheme => :query_string,
      :nonce => Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32] }

  
  def qq_client
    OAuth2::Client.new(app_id,app_key, :site => {:url =>HTT_URL,:response_type => 'code'})
  end
  


  def consumer_option
    { :oauth_consumer_key => app_id,
      :oauth_nonce =>OAUTH_CON,
      :oauth_signature=>signature_params,
      :oauth_signature_method => "HMAC-SHA1",
      :oauth_timestamp =>OAUTH_TIMESTAMP,
      :oauth_version => "1.0"
    }
    #          nonce =Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32]
  end
  def app_id
    223448
  end
  def app_key
    "64d7ddfe7e483dd51b2b14cf2ec0ec27"
  end

  def signature_params
    param="oauth_consumer_key=#{app_id}&oauth_nonce=#{OAUTH_CON}&oauth_signature_method=HMAC-SHA1& oauth_timestamp=#{OAUTH_TIMESTAMP}& oauth_version=1.0"
    #    puts "GET&#{url_encoding(HTT_URL)}&#{url_encoding(param)}"
    #    puts OpenSSL::HMAC.digest("sha1","#{app_key}&","GET&#{url_encoding(HTT_URL)}&#{url_encoding(param)}")
    return Base64.encode64(OpenSSL::HMAC.digest("sha1","#{app_key}&","GET&#{url_encoding(HTT_URL)}&#{url_encoding(param)}"))
    #      puts OPenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'),"GET&#{url_encoding(htt_url)}&#{url_encoding(param)}","#{app_key}&")
    #    return Base64.encode64(ruby_hmac("sha1", "GET&#{url_encoding(htt_url)}&#{url_encoding(param)}", "#{app_key}&", true))

  end

  def url_encoding(str)
    str.gsub("=", "%3D").gsub("/","%2F").gsub(":","%3A").gsub("&","%26 ")
  end

end
