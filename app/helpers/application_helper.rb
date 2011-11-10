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
    redirect_to "/sessions/new?last_url=#{request.url}"
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

  #返回是否已经参加
  def is_join_compete
     return ExamUser.find(:first,
      :conditions => ["user_id = ? and examination_id = ? and is_submited = #{ExamUser::IS_SUBMITED[:YES]}",
        cookies[:user_id].to_i, Constant::EXAMINATION.to_i])
  end

  #返回大赛的成绩和排名
  def compete_result
    exam_user = is_join_compete
    unless exam_user.nil? or is_join_compete.total_score.nil?
      xml = exam_user.open_xml
      scores = xml.get_elements("/result/blocks/block")
      tingli, yuedu, zonghe, zuowen = "0", "0", "0", "0"
      if scores[2].attributes["score"].to_f*10%10 == 0
        tingli = "#{scores[2].attributes["score"].to_i}"
      elsif scores[2].attributes["score"].to_f*10%10 <= 5
        tingli = "#{(scores[2].attributes["score"].to_f*10/10).to_i}" + ".5"
      else
        tingli = "#{(scores[2].attributes["score"].to_f*10/10).round}"
      end unless scores[2].nil? or scores[2].attributes["score"].nil? or scores[2].attributes["score"].to_i == 0

      second_score = (scores[1].nil? ? 0 :scores[1].attributes["score"].to_f) +
        (scores[3].nil? ? 0 :scores[3].attributes["score"].to_f) 
      if second_score.to_f*10%10 == 0
        yuedu = "#{second_score.to_i}"
      elsif second_score.to_f*10%10 <= 5
        yuedu = "#{(second_score.to_f*10/10).to_i}" + ".5"
      else
        yuedu = "#{(second_score.to_f*10/10).round}"
      end

      if scores[4].attributes["score"].to_f*10%10 == 0
        zonghe = "#{scores[4].attributes["score"].to_i}"
      elsif scores[4].attributes["score"].to_f*10%10 <= 5
        zonghe = "#{(scores[4].attributes["score"].to_f*10/10).to_i}" + ".5"
      else
        zonghe = "#{(scores[4].attributes["score"].to_f*10/10).round}"
      end unless scores[4].nil? or scores[4].attributes["score"].nil? or scores[4].attributes["score"].to_i == 0

      forth_score = (scores[0].nil? ? 0 :scores[0].attributes["score"].to_f) +
        (scores[5].nil? ? 0 :scores[5].attributes["score"].to_f)
      if forth_score.to_f*10%10 == 0
        zuowen = "#{forth_score.to_i}"
      elsif forth_score.to_f*10%10 <= 5
        zuowen = "#{(forth_score.to_f*10/10).to_i}" ".5"
      else
        zuowen = "#{(forth_score.to_f*10/10).round}"
      end
      return [tingli, yuedu, zonghe, zuowen, exam_user.id, exam_user.total_score, exam_user.rank]
    else
      return nil
    end
  end

end
