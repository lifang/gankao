#encoding: utf-8
class ExamUser < ActiveRecord::Base
  belongs_to :user
  has_many :rater_user_relations,:dependent=>:destroy
  belongs_to :examination
  has_many :exam_raters,:through=>:rater_user_relations,:foreign_key=>"exam_rater_id"
  belongs_to :paper

  require 'rexml/document'
  include REXML
  require 'spreadsheet'

  IS_SUBMITED = {:YES => 1, :NO => 0} #用户是否提交 1 提交 2 未提交
  IS_USER_AFFIREMED = {:YES => 1, :NO => 0} #用户是否确认  1 已确认 0 未确认
  IS_FREE = {:YES => 1, :NO => 0} #是否免费用户 1 是  0 否
  default_scope :order => "exam_users.total_score desc"
  #选择批阅试卷
  def self.get_paper(examination)
    if examination==Constant::EXAMINATION.to_i
      exam_users=ExamUser.find_by_sql("select e.id exam_user_id, r.id relation_id, r.is_marked ,
        r.exam_rater_id from exam_users e left join rater_user_relations r on r.exam_user_id= e.id
        where e.examination_id=#{examination} and e.answer_sheet_url is not null and e.is_submited=1")
    else
      exam_users=ExamUser.find_by_sql("select e.id exam_user_id, r.id relation_id, r.is_marked ,
        r.exam_rater_id from exam_users e inner join orders o on o.user_id = e.user_id
        left join rater_user_relations r   on r.exam_user_id= e.id
        where e.examination_id=#{examination} and e.answer_sheet_url is not null and e.is_submited=1")
    end
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

  #组装查询成绩的sql
  def ExamUser.generate_result_sql(options={})
    sql = "select u.id u_id,u.user_id user_id, e.id e_id, e.title e_title, e.description,e.start_at_time,
      c.name c_name,p.id p_id, p.total_score p_total_score, e.is_paper_open,
      p.total_question_num, us.name u_name, us.email, u.started_at, u.total_score u_total_score, u.answer_sheet_url
      from exam_users u inner join examinations e on e.id = u.examination_id
      inner join papers p on p.id = u.paper_id
      inner join users us on us.id = u.user_id
      left join categories c on c.id = p.category_id where 1=1 and u.answer_sheet_url is not null"
    options.each do |key, value|
      sql += " and #{key} #{value} "
    end unless options.empty?
    return sql
  end

  #显示单场考试的所有的考生成绩
  def ExamUser.return_exam_result(examination_id, pre_page, page)
    sql = generate_sql(examination_id)
    return ExamUser.paginate_by_sql(sql, :per_page =>pre_page, :page => page)
  end

  #显示单场考试成绩的等级
  def ExamUser.score_level_result(examination, exam_user_array)
    score_levels = examination.score_levels
    score_level_hash = {}
    exam_user_hash = {}
    score_levels.each do |score_level|
      scores = score_level.key.split("-")
      score_level_hash[score_level.value] = scores
      exam_user_hash[score_level.value] = 0
    end
    exam_user_array.each do |exam_user|
      score_level_hash.each do |key, value|
        if exam_user.total_score and ((exam_user.total_score >= value[0].to_i and exam_user.total_score <= value[1].to_i) or
              (exam_user.total_score <= value[0].to_i and exam_user.total_score >= value[1].to_i))
          exam_user_hash[exam_user.id] = key
          exam_user_hash[key] += 1
        end
      end
    end
    return exam_user_hash
  end

  def user_affiremed
    self.toggle!(:is_user_affiremed)
  end

  def submited!
    self.is_submited=1
    self.save
  end

  # <<<<head ==========================================================  综合训练记录result

  #创建考生综合训练答案
  def create_practice_result
    self.answer_sheet_url = self.create_practice_result_url(self.practice_result_xml_content, "result")
    self.save
  end

  def practice_result_xml_content
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    content += <<-XML
      <exam id='#{self.examination_id}' step='1'>
        <paper id='#{self.paper_id}' score='0'>
          <questions></questions>
        </paper>
      </exam>
    XML
    return content
  end

  #生成考生综合考试result文件
  def create_practice_result_url(str, path)
    dir = "#{Rails.root}/public/" + path + "/#{self.examination_id}"
    unless File.directory?(dir)
      Dir.mkdir(dir)
    end
    file_name = "/#{self.id}.xml"
    url = dir + file_name
    f=File.new(url,"w+")
    f.write("#{str.force_encoding('UTF-8')}")
    f.close
    return "/" + path + "/#{self.examination_id}" + file_name
  end

  #下一步
  def next_step(doc,url)
    step=doc.root.attributes['step']
    doc.root.attributes['step']=step.to_i+1
    f=File.new("#{Rails.root}/public#{url}","w+")
    f.write("#{doc.to_s.force_encoding('UTF-8')}")
    f.close
  end

  #设置step和check
  def set_step(doc,url,step=nil,check=nil)
    doc.root.attributes['check']=check if check
    doc.root.attributes['step']=step if step
    f=File.new("#{Rails.root}/public#{url}","w+")
    f.write("#{doc.to_s.force_encoding('UTF-8')}")
    f.close
  end

  #取得综合训练进度step
  def get_step(doc)
    arr=doc.root.attributes['step']
    #    arr<<doc.root.attributes['check']
    return arr
  end

  def practice_save_step_answer(doc,url,step,answer)
    if doc.root.elements["paper/blocks/block[#{step.to_i}]"]==nil
      blocks=doc.root.elements["paper/blocks"]
      block=blocks.add_element("block")
      answer.each do |single_answer|
        question=block.add_element("question")
        question.add_text(single_answer)
      end
      f=File.new("#{Rails.root}/public#{url}","w+")
      f.write("#{doc.to_s.force_encoding('UTF-8')}")
      f.close
    end

    block = doc.root.elements["blocks"].elements["block[@id='#{block_id}']"]
    problems = block.elements["problems"]
    problem = problems.add_element("problem")
    problem.add_attribute("id","#{self.id}")
    problem.add_attribute("types", "#{self.types}")
    title = problem.add_element("title")
    title.add_text("#{self.title}")
    problem.add_element("category").add_text("#{self.category_id}")
    problem.add_element("complete_title").add_text("#{self.complete_title}") unless self.complete_title.nil?
  end

  # >>>>end ===========================================================  综合训练记录result

  #考生更新考试时长信息
  def update_info_for_join_exam(exam_start_time = nil, exam_time)
    self.toggle!(:is_user_affiremed)
    self.started_at = Time.now
    self.ended_at = exam_start_time.nil? ? Time.now + exam_time.minutes :
      exam_start_time + exam_time.minutes unless exam_time.nil?
    self.answer_sheet_url = self.generate_answer_sheet_url(self.create_answer_xml, "result")
    self.save
  end


  
  #创建考生答卷
  def create_answer_xml(options = {})
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    content += <<-XML
      <exam id='#{self.examination_id}'>
        <paper id='#{self.paper_id}' score='0'>
          <questions></questions>
          <auto_score></auto_score>
          <rate_score></rate_score>
          <blocks></blocks>
        </paper>
      </exam>
    XML
    options.each do |key, value|
      content+="<#{key}>#{value.force_encoding('ASCII-8BIT')}</#{key}>"
    end unless options.empty?
    return content
  end

  #生成考生文件
  def generate_answer_sheet_url(str, path)
    dir = "#{Rails.root}/public/" + path + "/#{self.examination_id}"
    unless File.directory?(dir)
      Dir.mkdir(dir)
    end
    file_name = "/#{self.id}.xml"
    url = dir + file_name
    f=File.new(url,"w+")
    f.write("#{str.force_encoding('UTF-8')}")
    f.close
    return "/" + path + "/#{self.examination_id}" + file_name
  end

  def update_answer_url(doc, question_ids_options = {}, block_id = nil)
    questions = doc.root.elements["paper/questions"]
    questions.each_element { |q| doc.delete_element(q.xpath) }if questions.children.any?
    question_ids_options.each do |key, value|
      question = questions.add_element("question")
      question.add_attribute("id","#{key}")
      question.add_attribute("score","0")
      answer = value[0].nil? ? "" : value[0].strip
      is_sure = value[1].nil? ? "" : value[1].strip
      question.add_element("answer").add_text("#{answer}")
      question.add_attribute("is_sure", "#{is_sure}")
    end unless question_ids_options == {}
    unless block_id.nil?
      block_ids = block_id.split(",")
      blocks = doc.root.elements["paper/blocks"]
      unless blocks.nil?
        blocks.each_element { |b| doc.delete_element(b.xpath) }if blocks.children.any?
        block_ids.each do |b_id|
          block = blocks.add_element("block")
          block.add_attribute("id","#{b_id}")
          block.add_attribute("score","0")
        end
      end
    end
    return doc.to_s
  end

  def open_xml
    dir = "#{Rails.root}/public"
    url = File.open(dir + self.answer_sheet_url)
    doc=Document.new(url)
    url.close
    return doc
  end

  #自动统计考试的分数
  def self.generate_user_score(answer_doc, paper_doc)
    auto_score = 0
    paper_doc.root.elements["blocks"].each_element do |block|
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          if question.attributes["correct_type"].to_i != Problem::QUESTION_TYPE[:CHARACTER]
            q_answer = answer_doc.root.elements["paper/questions"].elements["question[@id='#{question.attributes["id"]}']"]
            unless q_answer.nil? or q_answer.elements["answer"].nil?
              score = 0
              if q_answer.elements["answer"].text and q_answer.elements["answer"].text != ""
                answers = question.elements["answer"].text.split(";|;")
                if answers.length == 1
                  score = answers[0].strip == q_answer.elements["answer"].text.strip ? question.attributes["score"].to_i : 0
                else
                  q_answers = q_answer.elements["answer"].text.split(";|;")
                  all_answer = answers | q_answers
                  if all_answer == answers
                    if answers - q_answers == []
                      score = question.attributes["score"].to_i
                    elsif q_answers.length < answers.length
                      score = ((question.attributes["score"].to_i.to_f)/2).round
                    end
                  elsif all_answer.length > answers.length
                    score = 0
                  end
                end
              end
              q_answer.add_attribute("score", "#{score}")
              auto_score += score
            end
          end
        end unless problem.elements["questions"].nil?
      end
    end
    answer_doc.root.elements["paper"].elements["auto_score"].text = auto_score
    rate_score = answer_doc.root.elements["paper"].elements["rate_score"]
    total_score = auto_score
    unless rate_score.text.nil? or rate_score.text == ""
      total_score += answer_doc.root.elements["paper"].elements["rate_score"].text.to_i
    end
    answer_doc.root.elements["paper"].add_attribute("score", "#{total_score}")
    return answer_doc
  end

  #自动批卷完成
  def set_auto_rater(total_score=nil)
    self.total_score = total_score
    self.toggle!(:is_auto_rate)
    self.save
  end

  #判断考生是否存在
  def self.is_exam_user_in(paper_id, examination_id, user_id)
    exam_user = ExamUser.find_by_sql(["select e.id, e.user_id, e.answer_sheet_url, p.paper_url from exam_users e
        inner join papers p on p.id = e.paper_id
        where e.paper_id = ? and e.examination_id = ? and e.user_id = ? limit 1", examination_id, paper_id, user_id])
    return exam_user[0]
  end

  #显示答卷
  def self.show_result(paper_id, doc)
    @xml = ExamRater.open_file(Constant::BACK_PUBLIC_PATH + "/papers/#{paper_id}.xml")
    @xml.elements["blocks"].each_element do  |block|
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          unless doc.nil? or doc.elements["paper"].elements["questions"].nil?
            element = doc.elements["paper/questions/question[@id=#{question.attributes["id"]}]"]
            unless element.nil?
              answer = (element.elements["answer"].nil? or element.elements["answer"].text.nil?) ? "" :
                element.elements["answer"].text
              question.add_attribute("user_answer","#{answer}")
              question.add_attribute("user_score","#{element.attributes["score"]}")
              reason = element.attributes["score_reason"].nil? ? "" : element.attributes["score_reason"]
              question.add_attribute("score_reason","#{reason}")
            end
          end
        end unless problem.elements["questions"].nil?
      end
    end
    return @xml
  end

  #筛选题目
  def self.answer_questions(xml,doc)
    str="-1"
    xml.elements["blocks"].each_element do  |block|
      block.elements["problems"].each_element do |problem|
        block.delete_element(problem.xpath) if problem.attributes["types"].nil?
        if problem.attributes["types"] != nil and 
            (problem.attributes["types"].to_i == Problem::QUESTION_TYPE[:CHARACTER] or
              problem.attributes["types"].to_i == Problem::QUESTION_TYPE[:COLLIGATION] or
              problem.attributes["types"].to_i == Problem::QUESTION_TYPE[:SINGLE_CALK])
          problem.elements["questions"].each_element do |question|
            element=doc.elements["paper/questions/question[@id=#{question.attributes["id"]}]"]
            if question.attributes["correct_type"].to_i ==Problem::QUESTION_TYPE[:CHARACTER] or
                question.attributes["correct_type"].to_i == Problem::QUESTION_TYPE[:SINGLE_CALK]
              str += (","+question.attributes["id"])
              answer = (element.nil? or element.elements["answer"].nil? or element.elements["answer"].text.nil?) ? ""
              : element.elements["answer"].text
              question.add_attribute("user_answer","#{answer}")
            else
              problem.delete_element(question.xpath)
            end
          end unless problem.elements["questions"].nil?
          block.delete_element(problem.xpath) if problem.elements["questions"].nil? or
            problem.elements["questions"].elements.size <= 0
        else       
          block.delete_element(problem.xpath)
        end       
      end unless block.elements["problems"].nil?
      if block.elements["problems"].nil? or block.elements["problems"].elements.size<=0
        xml.delete_element(block.xpath)
      end
    end unless xml.elements["blocks"].nil?
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
    exam_user = ExamUser.find(user_id)
    url="#{Constant::PUBLIC_PATH}/#{exam_user.answer_sheet_url}"
    doc=ExamRater.open_file(url)
    doc.elements["paper"].elements["questions"].each_element do |question|
      if question.attributes["id"]==id
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
      if !examination[0].is_submited.nil? and (examination[0].is_submited == true or examination[0].is_submited == 1)
        str = "您已经交卷。"
      else
        if examination[0].paper_id.nil? and examination[0].start_at_time > Time.now
          str = "本场考试开始时间为#{examination[0].start_at_time.strftime("%Y-%m-%d %H:%M:%S")},请您做好准备。"
        elsif (!examination[0].start_at_time.nil? and !examination[0].exam_time.nil? and examination[0].exam_time !=0 and
              (examination[0].start_at_time + examination[0].exam_time.minutes) < Time.now) or
            examination[0].status == Examination::STATUS[:CLOSED]
          str = "本场考试已经结束。"
        elsif examination[0].paper_id.nil? and examination[0].start_end_time  < Time.now
          str = "您不能入场，本场考试入场时间为#{examination[0].start_at_time.strftime("%Y-%m-%d %H:%M:%S")}
              -#{examination[0].start_end_time.strftime("%Y-%m-%d %H:%M:%S")}。"
        end if examination[0].start_at_time
      end
    else
      str = "本场考试已经取消，或者您没有资格参加本场考试。"
    end
    return [str, examination]
  end

  #计算正确率并把错误的试题加进错题集
  def auto_add_collection(question_hash)
    xml = ExamRater.open_file("#{Constant::BACK_PUBLIC_PATH}/papers/#{self.paper_id}.xml")
    collection = Collection.find_or_create_by_user_id(self.user_id)
    collection.set_collection_url
    collection_xml = collection.open_xml
    correct_num = 0
    xml.elements["blocks"].each_element do |block|
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |xml_question|
          if xml_question.attributes["correct_type"].to_i != Problem::QUESTION_TYPE[:CHARACTER] &&
              xml_question.attributes["correct_type"].to_i != Problem::QUESTION_TYPE[:SINGLE_CALK]
            if xml_question.elements["answer"] and xml_question.elements["answer"].text
              answer = xml_question.elements["answer"].text
              answers = answer.split(";|;")
              user_answer = question_hash[xml_question.attributes["id"]][0]
              if user_answer
                user_answers = user_answer.split(";|;")
                all_answer = answers | user_answers
                if all_answer == answers and (answers - user_answers == [])
                  problem.delete_element(xml_question.xpath)
                  correct_num +=1
                else
                  collection_xml = self.add_collection(collection, xml, collection_xml, problem, xml_question, user_answer.strip)
                end
              end
            end
          end
        end unless problem.elements["questions"].nil?
      end
    end unless question_hash.empty?
    collection.generate_collection_url(collection_xml.to_s)
    self.update_attributes(:correct_percent => ((correct_num.to_f/xml.attributes["total_num"].to_f)*100).round)
  end

  #添加收藏
  def add_collection(collection, paper_xml, collection_xml, problem, question, user_answer)
    collection_problem = collection.problem_in_collection(problem.attributes["id"], collection_xml)
    if collection_problem
      collection_question = collection.question_in_collection(collection_problem, question.attributes["id"])
      if collection_question
        collection_xml = collection.update_question(user_answer, collection_question.xpath, collection_xml)
      else
        collection_xml = collection.add_question(question, user_answer, collection_problem, collection_xml)
      end
    else
      collection_xml = collection.auto_add_problem(paper_xml, question.attributes["id"], problem.xpath, user_answer, collection_xml)
    end
    return collection_xml
  end

  #返回用户当前提点的答案
  def return_question_answer(question_id)
    doc = ExamRater.open_file("#{Constant::PUBLIC_PATH}#{self.answer_sheet_url}")
    return doc.elements["/exam/paper/questions/question[@id='#{question_id}']/answer"]
  end


  #返回用户参与的不同考试类型的次数
  def self.return_join_exam_count(types, user_id,category_id)
    exam_sums = Examination.find_by_sql("select count(eu.id) count_id from exam_users eu
      inner join examinations ex on eu.examination_id = ex.id
      where eu.is_submited = #{ExamUser::IS_SUBMITED[:YES]} and ex.category_id=#{category_id} and ex.types = #{types} and eu.user_id = #{user_id}")
    return exam_sums[0] ? exam_sums[0].count_id : 0
  end
  

end
