class ExamUser < ActiveRecord::Base
  belongs_to :user
  has_many :rater_user_relations,:dependent=>:destroy
  belongs_to :examination
  has_many :exam_raters,:through=>:rater_user_relations,:foreign_key=>"exam_rater_id"
  belongs_to :paper

  require 'rexml/document'
  include REXML
  require 'spreadsheet'

  IS_USER_AFFIREMED = {:YES => 1, :NO => 0} #用户是否确认  1 已确认 0 未确认
  default_scope :order => "exam_users.total_score desc"
  #选择批阅试卷
  def self.get_paper(examination)
    exam_users=ExamUser.find_by_sql("select e.id exam_user_id, r.id relation_id, r.is_marked from exam_users e
        left join rater_user_relations r on r.exam_user_id= e.id
        where e.examination_id=#{examination} and e.answer_sheet_url is not null ")
    return exam_users
  end
  #分页显示单场考试的所有成绩
  def ExamUser.paginate_exam_user(examination_id, pre_page, page, options={})
    sql = ExamUser.generate_sql(examination_id, options)
    return Examination.paginate_by_sql(sql, :per_page =>pre_page, :page => page)
  end
  

  #显示单场考试的所有的考生
  def ExamUser.select_exam_users(examination_id, options={})
    sql = generate_sql(examination_id, options)
    return Examination.find_by_sql(sql)
  end

  
  #组装查询学生的sql语句
  def ExamUser.generate_sql(examination_id, options={})
    sql = "select e.examination_id, e.id, e.user_id, e.is_user_affiremed, e.is_submited,
        e.open_to_user, e.answer_sheet_url, u.name, u.mobilephone, u.email, e.total_score
        from exam_users e inner join users u on u.id = e.user_id
        where e.examination_id = #{examination_id} "
    options.each do |key, value|
      sql += " and #{key} #{value} "
    end unless options.empty?
    return sql
  end

  #随机分配学生一张试卷
  def set_paper(examination)
    papers = examination.papers
    self.paper = papers[rand(papers.length-1)]
    self.save
  end

  def open_xml
    dir = "#{Rails.root}/public"
    url = File.open(dir + self.answer_sheet_url)
    return Document.new(url)
  end
  #显示答卷
  def self.show_result(paper_id, doc)
    @xml = ExamRater.open_file("/papers/#{paper_id}.xml")
    @xml.elements["blocks"].each_element do  |block|
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          doc.elements["paper"].elements["questions"].each_element do |element|
            if element.attributes["id"]==question.attributes["id"]
              question.add_attribute("user_answer","#{element.elements["answer"].text}")
              question.add_attribute("user_score","#{element.attributes["score"]}")
            end
          end
        end
      end
    end
    return @xml
  end

  #筛选题目
  def self.answer_questions(xml,doc)
    str="-1"
    xml.elements["blocks"].each_element do  |block|
      block.elements["problems"].each_element do |problem|
        if (problem.attributes["types"].to_i !=Problem::QUESTION_TYPE[:CHARACTER] and
              problem.attributes["types"].to_i !=Problem::QUESTION_TYPE[:COLLIGATION])
          block.delete_element(problem.xpath)
        else
          problem.elements["questions"].each_element do |question|
            doc.elements["paper"].elements["questions"].each_element do |element|
              if element.attributes["id"]==question.attributes["id"]
                question.add_attribute("user_answer","#{element.elements["answer"].text}")
              end
            end
            if question.attributes["correct_type"].to_i ==Problem::QUESTION_TYPE[:CHARACTER]
              str += (","+question.attributes["id"])
            else
              problem.delete_element(question.xpath)
            end           
          end
        end
        block.delete_element(problem.xpath) if problem.elements["questions"].elements[1].nil?
      end
    end
    xml.add_attribute("ids","#{str}")
    return xml
  end

  #批量验证考生
  def self.judge(info,id)
    str=""
    hash =get_email(info)
    users =User.find_by_sql(["select u.*,e.examination_id e_id from users u left join exam_users e on u.id=e.user_id
                             where u.email in(?) ", hash.keys])
    users.each do |user|
      str += user.name + "," + user.email + ";" unless user.name == hash["#{user.email}"][0]
      str += user.name + "," + user.email + ";" if user.e_id == id
    end if users
    return str
  end

  #批量添加考生
  def self.login(info,examination)
    hash =get_email(info)
    users = User.find_by_sql(["select * from users u where u.email in (?)",hash.keys])
    users.each do |user|
      examination.new_exam_user(user)
      hash.delete(user.email)
    end if users
    hash.each do |email|
      user = User.auto_add_user(email[1][0].strip,email[1][0].strip, email[0].strip,email[1][1].strip)
      examination.new_exam_user(user)
    end
  end

  #获取批量的email
  def self.get_email(info)
    hash = {}
    0.step(info.length-1, 3).each do |i|
      hash[info[i+1].strip] = ["#{info[i].strip}", "#{info[i+2].strip}"]
    end
    return hash
  end

  #编辑考分
  def self.edit_scores(user_id,id,score)
    url="/result/#{user_id}.xml"
    doc=ExamRater.open_file(url)
    doc.elements["paper"].elements["questions"].each_element do |question|
      if question.attributes["id"]==id
        exam_user=ExamUser.find(user_id)
        exam_user.total_score += (score.to_i-question.attributes["score"].to_i )
        doc.elements["paper"].attributes["score"]=exam_user.total_score
        exam_user.save
        question.attributes["score"]=score
      end
    end
    Problem.write_xml("#{Rails.root}/public"+url, doc)
  end

  #导出当前考试未确认的考生名单
  def self.export_user_unaffirm(url, examination_id)
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
       sheet.row(0).concat %w{姓名 手机号 邮箱}
    exam_users = ExamUser.find_by_sql("select u.name, u.mobilephone, u.email from exam_users e
        inner join users u on e.user_id = u.id where examination_id=#{examination_id} and is_user_affiremed != 1")
    exam_users.each_with_index do |exam_user, index|
      sheet.row(index+1).concat ["#{exam_user.name}", "#{exam_user.mobilephone}", "#{exam_user.email}"]
    end
    book.write url
  end

  #检验当前当前考生是否能考本场考试

  def self.can_answer(user_id, examination_id)
    str = ""
    examination = Examination.return_examinations(user_id, examination_id)
    if examination.any?
      if !examination[0].is_submited.nil? and examination[0].is_submited == 1
        str = "您已经交卷。"
      else
        if examination[0].exam_user_id.nil? and examination[0].status == Examination::STATUS[:GOING]
          examination[0].new_exam_user(User.find(user_id))
        else
          if examination[0].start_at_time > Time.now
            str = "本场考试开始时间为#{examination[0].start_at_time.strftime("%Y-%m-%d %H:%M:%S")},请您做好准备。"
          elsif (!examination[0].exam_time.nil? and examination[0].exam_time !=0 and
                (examination[0].start_at_time + examination[0].exam_time.minutes) < Time.now) or
              examination[0].status == Examination::STATUS[:CLOSED]
            str = "本场考试已经结束。"
          elsif examination[0].start_end_time  < Time.now
            str = "您不能入场，本场考试入场时间为#{examination[0].start_at_time.strftime("%Y-%m-%d %H:%M:%S")}
              -#{examination[0].start_end_time.strftime("%Y-%m-%d %H:%M:%S")}。"
          end if examination[0].start_at_time
        end
      end
    else
      str = "本场考试已经取消，或者您没有资格参加本场考试。"
    end
    return [str, examination]
  end
end
