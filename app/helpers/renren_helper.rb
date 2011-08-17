module RenrenHelper
  require 'oauth2'
  require 'net/http'
  TOTAL_GRAPH_URL = "https://graph.renren.com"
  GRAPH_RENREN_URL = "graph.renren.com"
  CALL_BACK_URL = Constant::SERVER_PATH + "/pages/renren_index"
  ACCESS_TOKEN_URL = "/oauth/token"
  API_RENREN_URL = "http://api.renren.com/restserver.do"
  SESSION_KEY_URL = "/renren_api/session_key"

  def client
    OAuth2::Client.new(api_key, api_secret,
      :site => {:url => TOTAL_GRAPH_URL,:response_type => 'code'})
  end

  #返回access_token
  def return_access_token(code)
    http = Net::HTTP.new(GRAPH_RENREN_URL, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.get(access_token_url(code))
    res_json = JSON res.body
    return res_json["access_token"]
  end
  
  
  def return_session_key(access_token)
    http = Net::HTTP.new(GRAPH_RENREN_URL, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    session_res = http.get(session_key_url(access_token))
    res_json = JSON session_res.body
    return res_json["renren_token"]["session_key"]
  end

  #返回用户信息
  def return_user(session_key)
    str = "api_key=#{api_key}"
    str << "call_id=#{Time.now.to_i}"
    str << "format=JSON"
    str << "method=xiaonei.users.getInfo"
    str << "session_key=#{session_key}"
    str << "v=1.0"
    str << "#{api_secret}"
    sig = Digest::MD5.hexdigest(str)

    query = {:api_key => api_key,
      :call_id => Time.now.to_i,
      :format => 'JSON',
      :method => 'xiaonei.users.getInfo',
      :session_key => session_key,
      :v => '1.0',
      :sig => sig
    }
    return JSON Net::HTTP.post_form(URI.parse(URI.encode("http://api.renren.com/restserver.do")), query).body
  end

  def api_key
    "7f4d7bacf5b144d8940d5a8177b592b0"
  end

  def api_secret
    "fe0430b144ff4cb48f1060933e1f68b0"
  end

  def access_token_url(code)
    grant_type = "grant_type=authorization_code"
    access_code = "code=#{code}"
    client_id = "client_id=" + api_key
    client_secret = "client_secret=" + api_secret
    redirect_uri = "redirect_uri=" + CALL_BACK_URL
    return ACCESS_TOKEN_URL + "?" + grant_type + "&"+ access_code +"&" + client_id + "&"+ client_secret + "&" + redirect_uri
  end

  def session_key_url(access_token)
    return SESSION_KEY_URL + "?oauth_token=" + access_token
  end

end
