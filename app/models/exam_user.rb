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

 
  
end
