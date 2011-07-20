module ApplicationHelper
  def re_h(html)
    return "" if html.blank? or html.nil?
    html.to_s.gsub("&amp;","&").gsub("&quot;","\"" ).gsub("&gt;",">").gsub("&lt;","<" )
  end

  def use_validate_js_tooltip
    html   = javascript_include_tag "validation_cn"
    html  += javascript_include_tag "tooltips"
    html  += javascript_include_tag "prototip"
    html  += stylesheet_link_tag "/stylesheets/validates/tooltips.css"
    html
  end

  # 中英文混合字符串截取
  def truncate_u(text, length = 30, truncate_string = "......")
    l=0
    char_array=text.unpack("U*")
    char_array.each_with_index do |c,i|
      l = l+ (c<127 ? 0.5 : 1)
      if l>=length
        return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
      end
    end
    return text
  end

  def current_user
    User.find_by_id(cookies[:user_id])
  end

  def deny_access
    redirect_to "/"
  end

  def signed_in?
    return cookies[:user_id] != nil
  end


  def username_used
    flash[:notice] = "用户名已经存在,请重新输入！"
    redirect_to "/users/new"
  end

  def unused?
    return session[:user_email] == nil
  end

  def title
    return @title.nil? ? "赶考" : @title
  end
end
