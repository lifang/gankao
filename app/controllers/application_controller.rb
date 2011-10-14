#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include RemotePaginateHelper
  include Constant
  include UserRoleHelper
  include RenrenHelper
  include QqHelper
  before_filter :auto_login
  

  def access?
    deny_access unless signed_in?
  end

  def write_xml(url,doc)
    file = File.new(url, "w+")
    file.write(doc)
    file.close
  end

  def proof_code(len)
    #    chars = ('A'..'Z').to_a + ('a'..'z').to_a
    chars = (1..9).to_a
    code_array = []
    1.upto(len) {code_array << chars[rand(chars.length)]}
    return code_array.join("")
  end

  def get_text(text)
    @text=text.gsub /['\n''\t''\b'' ']/," "
    @grade=@text.split(" ")
    return @grade
  end



  #总体处理错误
  def rescue_action_in_public(exception)
    case exception
    when ActiveRecord::RecordNotFound
      render :file => "#{Rails.root}/public/error.html"
    when NoMethodError, ActionController::RoutingError
      render :file => "#{Rails.root}/public/error.html"
    when Rails.logger.error("404 displayed")
      render(:file => "#{Rails.root}/public/404.html", :status => "404 Error")
    else Rails.logger.error("500 displayed")
      render(:file => "#{Rails.root}/public/500.html", :status => "500 Error")
    end
  end


  def auto_login
    if cookies[:user_id]==nil&&cookies[:is_auto_login]!=nil&&cookies[:is_auto_login]!=""
      cookies[:user_id] = cookies[:is_auto_login]
      cookies[:user_name] = User.find(cookies[:is_auto_login]).name
      cookie_role(cookies[:user_id])
    end
  end

end