#encoding: utf-8
class Examination < ActiveRecord::Base
  has_many :examination_paper_relations,:dependent => :destroy
  has_many :papers,:through=>:examination_paper_relations, :source => :paper
  has_many :score_levels,:dependent=>:destroy
  belongs_to :user,:foreign_key=>"creater_id"
  has_many :exam_users,:dependent => :destroy
  has_many :exam_raters,:dependent => :destroy
  belongs_to :category
  STATUS = {:EXAMING => 0, :LOCK => 1, :GOING => 2,  :CLOSED => 3 } #考试的状态：0 考试中 1 未开始 2 进行中 3 已结束
  IS_PUBLISHED = {:NEVER => 0, :ALREADY => 1} #是否发布  0 没有 1 已经发布

  TYPES = {:SIMULATION => 0, :OLD_EXAM => 1, :PRACTICE => 2} #考试的类型： 0 模拟考试  1 真题练习  2 综合训练

  TYPE_NAMES = {:SIMULATION => [0, "模拟考试"], :OLD_EXAM => [1, "真题练习"], :PRACTICE => [2, "综合训练"]}
  default_scope :order => "examinations.created_at"

  #创建考试
  def update_examination(attr_hash)
    attr_hash[:is_published] = IS_PUBLISHED[:NEVER]
    unless attr_hash[:generate_exam_pwd].nil?
      generate_exam_pwd(attr_hash) if attr_hash[:generate_exam_pwd]
      attr_hash.delete(:generate_exam_pwd)
    end
    self.update_attributes(attr_hash)
    self.publish!
    #return examination
  end

  def generate_exam_pwd(attr_hash)
    attr_hash[:exam_password1] = proof_code(6)
    attr_hash[:exam_password2] = proof_code(6)
  end

  #发布考试
  def publish!
    self.toggle!(:is_published)
  end

  #考试组织人员添加考生添加考试记录账号
  def new_exam_user(user)
    exam_user = ExamUser.create(:user_id => user.id,:examination_id => self.id,:password => User::DEFAULT_PASSWORD,
      :is_user_affiremed => ExamUser::IS_USER_AFFIREMED[:NO])
    exam_user.set_paper(self)
    UserMailer.user_affirmed(exam_user,self).deliver if self.user_affirm == true
  end

  #修改试卷,此方法用来修改考试试卷，update_flag 是传过来增加或删除的标记，papers是试卷数组
  def update_paper(update_flag, papers)
    if update_flag == "create"
      papers.each do |i|
        self.papers << i
        i.set_paper_used!
      end
    else
      if papers.size > 1
        papers.each { |i| self.papers.delete(i) }
      else
        self.papers.delete(papers)
      end
    end
  end

  def Examination.search_method(user_id, start_at, end_at, title, pre_page, page)
    sql = "select * from examinations e where creater_id = #{user_id} and is_published = 1 "
    sql += "and e.created_at >= '#{start_at}' " unless start_at.nil?
    sql += "and e.created_at <= '#{end_at}' " unless end_at.nil?
    sql += "and e.title like '%#{title}%' " unless title.nil?
    sql += "order by e.status asc, e.created_at desc "
    puts sql
    return Examination.paginate_by_sql(sql, :per_page =>pre_page, :page => page)
  end

  def update_score_level(score_array)
    self.score_levels = []
    0.step(score_array.length-1, 2) do |i|
      ScoreLevel.create(:examination_id=>self.id,:key=>score_array[i],:value=>score_array[i+1])
    end
  end

  def proof_code(len)
    chars = (1..9).to_a
    code_array = []
    1.upto(len) {code_array << chars[rand(chars.length)]}
    return code_array.join("")
  end

  #显示单个登录考生能看到的所有的考试
  def Examination.return_examinations(user_id, examination_id = nil)
    sql = "select e.*, eu.id exam_user_id, eu.paper_id, eu.started_at, eu.ended_at, eu.is_submited from examinations e
          left join exam_users eu on e.id = eu.examination_id
          where e.is_published = #{IS_PUBLISHED[:ALREADY]} and e.status != #{STATUS[:CLOSED]} "
    sql += " and e.id = #{examination_id} " if !examination_id.nil? and examination_id != ""
    sql += " and eu.user_id = #{user_id} "    
    Examination.find_by_sql(sql)
  end

  #判断是否能打包购买
  def self.can_packge_by(category_id)
    can_by = true
    if category_id
      examination = Examination.first(:conditions => "category_id = #{category_id.to_i}", :order => "exam_free_end_at asc")
      can_by = false if !examination.exam_free_end_at.nil? and examination.exam_free_end_at < Time.now
    end
    return can_by
  end

  def is_user_in(user_id)
    exam_user = ExamUser.where(["user_id = ? and examination_id = ?", user_id, self.id]).first
    is_in = exam_user.nil? ? false : true
    return is_in
  end

  def self.exam_users_hash(user_id,types,category_id)
    hash ={}
    ExamUser.find_by_sql("select eu.id eu_id, eu.total_score,eu.is_submited,eu.examination_id,eu.created_at
        correct_percent from exam_users eu inner join examinations e on e.id = eu.examination_id
        where e.types =#{types} and eu.user_id = #{user_id} and e.category_id=#{category_id} and eu.is_submited = #{ExamUser::IS_SUBMITED[:YES]}
        and is_published = #{Examination::IS_PUBLISHED[:ALREADY]}").each do |exam_user|
      hash["#{exam_user.examination_id}"] = exam_user
    end unless user_id.nil? or user_id == ""
    return hash
  end

  def self.return_page_element(doc, has_next_page)
    current_num = 0
    doc.elements["/collection/problems"].each_element do |problem|
      if current_num >= 1
        doc.delete_element(problem.xpath)
        has_next_page = true unless has_next_page
      end
      current_num += 1
      
    end
    return [doc, has_next_page]
  end


  #返回开始显示的节点
  def self.get_start_element(page, doc)
    start_num = (page.nil? or page == "" or page == "1") ? 0 : (page.to_i-1) * 1
    doc.root.elements['problems'].each_element do |problem|
      doc.delete_element(problem.xpath) if start_num > 0
      start_num -= 1
    end if start_num > 0
    return doc
  end

  #返回真题的正确率
  def self.count_correct(id,category_id)
    correct = 0
    users = ExamUser.find_by_sql("select count(eu.id) count_id, sum(eu.correct_percent) correct_percent
        from exam_users eu inner join examinations e on e.id = eu.examination_id
        where is_published = #{Examination::IS_PUBLISHED[:ALREADY]} and e.category_id = #{category_id} and eu.is_submited = 1
        and eu.user_id = #{id} and e.types = #{TYPES[:OLD_EXAM]}")
    correct = users[0].count_id == 0 ? 0 : (users[0].correct_percent/users[0].count_id).round if users and users[0]
    return correct
  end

  #返回不同的考试类型的次数
  def self.return_exam_count(types,category_id)
    return Examination.count(:id,
      :conditions => "is_published = #{Examination::IS_PUBLISHED[:ALREADY]}
          and status != #{Examination::STATUS[:CLOSED]} and category_id=#{category_id} and types = #{types}")
  end

  #返回综合训练的总数（包括关闭的）
  def self.return_all_exam_count(types,category_id)
    return Examination.count(:id,
      :conditions => "is_published = #{Examination::IS_PUBLISHED[:ALREADY]}
          and category_id=#{category_id} and types = #{types}")
  end

  #随机返回用户一条试卷记录

  def self.rand_examnation(types, user_id, category_id)
    Examination.find_by_sql("select e.id from examinations e where e.id not in(select ex.id count_id from exam_users eu
      inner join examinations ex on eu.examination_id = ex.id
      where eu.is_submited = #{ExamUser::IS_SUBMITED[:YES]} and ex.types = #{types} and eu.user_id = #{user_id})
       and e.is_published = #{Examination::IS_PUBLISHED[:ALREADY]} and e.category_id = #{category_id}
       and status != #{Examination::STATUS[:CLOSED]} and types = #{types} order by rand() limit 1")
  end


  def self.exam_users_paper(user_id,types,category_id)
    hash ={}
    ExamUser.find_by_sql("select eu.id,eu.total_score,eu.is_submited,eu.examination_id,eu.paper_id,eu.created_at,
        eu.correct_percent from exam_users eu inner join examinations e on e.id = eu.examination_id
        where e.types =#{types} and eu.user_id = #{user_id} and e.category_id=#{category_id} and eu.is_submited=1
        and is_published=#{Examination::IS_PUBLISHED[:ALREADY]}").each do |exam_user|
      doc=ExamRater.open_file("#{Constant::BACK_PUBLIC_PATH}/papers/#{exam_user.paper_id}.xml") unless exam_user.paper_id.nil?
      xml=ExamRater.open_file("#{Constant::PUBLIC_PATH}/result/#{exam_user.examination_id}/#{exam_user.id}.xml") unless exam_user.paper_id.nil?
      hash["#{exam_user.examination_id}"] = [exam_user,doc,xml]
    end unless user_id.nil? or user_id == ""
    return hash
  end
end
