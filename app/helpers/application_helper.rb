#encoding: utf-8
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
    redirect_to "/sessions/new"
  end

  def signed_in?
    return cookies[:user_id] != nil
  end

#  def has_incorrect?
#    return Collection.find()
#  end

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

  def handle_paginate(page, total_page)
    html = ""
    if page and page.to_i > 1
      html += "<a href='#{request.path}?page=#{page.to_i - 1}'>&lt;</a>"
    else
      html += "<span class='disabled'> &lt; </span>"
    end
    current_page = (page and page.to_i > 1) ? page.to_i : 1
    if total_page > 12
      if current_page <= 6
        (1..current_page).each do |i|
          if current_page == i
            html += "<span class='current'>#{i}</span>"
          else
            html += "<a href='#{request.path}?page=#{i}'>#{i}</a>"
          end
        end
      else
        (1..2).each do |i|
          html += "<a href='#{request.path}?page=#{i}'>#{i}</a>"
        end
        end_page = (total_page - current_page) < 6 ? current_page -2 : current_page
        html += "..." if (end_page -3) > 3
        ((end_page-3)..current_page).each do |i|
          if current_page == i
            html += "<span class='current'>#{i}</span>"
          else
            html += "<a href='#{request.path}?page=#{i}'>#{i}</a>"
          end
        end
      end
      if current_page + 5 >= total_page
        ((current_page+1)..total_page).each do |i|
          html += "<a href='#{request.path}?page=#{i}'>#{i}</a>"
        end
      else
        start_page = current_page+3 <= 6 ? current_page + 2 : current_page
        ((current_page+1)..start_page+3).each do |i|
          html += "<a href='#{request.path}?page=#{i}'>#{i}</a>"
        end
        html += "..." if start_page+4 < (total_page-1)
        ((total_page-1)..total_page).each do |i|
          html += "<a href='#{request.path}?page=#{i}'>#{i}</a>"
        end
      end
    else
      (1..total_page).each do |i|
        if current_page == i
          html += "<span class='current'>#{i}</span>"
        else
          html += "<a href='#{request.path}?page=#{i}'>#{i}</a>"
        end
      end
    end
    
    
    if page.to_i < total_page
      html += "<a href='#{request.path}?page=#{current_page + 1}'>&gt;</a>"
    else
      html += "<span class='disabled'> &gt; </span>"
    end
    return html.html_safe
  end

end
