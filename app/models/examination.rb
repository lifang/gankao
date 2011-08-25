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

  TYPES = {:SIMULATION => 0, :OLD_EXAM => 1, :PRACTICE1 => 2, :PRACTICE2 => 3, :PRACTICE3 => 4, :PRACTICE4 => 5,
    :PRACTICE5 => 6} #考试的类型： 0 模拟考试  1 真题练习  2 综合训练1  3 综合训练2  4 综合训练3  5 综合训练4  6 综合训练5
  #  TYPE_NAMETYPESS = {:SIMULATION => [0, "模拟考试"], :OLD_EXAM => [1, "真题练习"], :PRACTICE1 => [2, "综合训练1"],
  #    :PRACTICE2 => [3, "综合训练2"], :PRACTICE3 => [4, "综合训练3"], :PRACTICE4 => [5, "综合训练4"], :PRACTICE5 => [6, "综合训练5"]}
  #default_scope :order => "examinations.created_at desc"

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
          where e.is_published = 1 and e.status != #{STATUS[:CLOSED]} "
    sql += " and e.id = #{examination_id} " if !examination_id.nil? and examination_id != ""
    if user_id
      sql += "and ((e.status = #{STATUS[:GOING]} and eu.id is null) or eu.user_id = #{user_id}) "
    else
      sql += "and (e.status = #{STATUS[:GOING]}) "
    end
    sql += "order by e.created_at desc"
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

  def calculation_confidence
    user =User.find(cookies[:user_id])
    simulation_belief=0
    def return_sum(types,user)
      sql="select count(e.id) sum from examinations  e left join exam_users u on u.examination_id=e.id where 1=1"
      if types.to_s.length==1
        sql += " and e.types=#{types}"
      else
        sql += " and e.types in (#{types})"
      end
      sql += " and u.user_id=#{cookies[:user_id]}" if user==1
      return ExamUser.find_by_sql(sql)[0].sum*1.0
    end
    num=return_sum(Examination::TYPES[:SIMULATION],1).to_i
    simulation_belief=0.5 if num >=1
    simulation_belief=0.8 if num>=2
    simulation_belief=1 if num>=3
    puts simulation_belief
    old_percent=return_sum(Examination::TYPES[:OLD_EXAM],1)/return_sum(Examination::TYPES[:OLD_EXAM],0)
    puts 4.0/7
    puts old_percent
    collect_percent=return_sum("2,3,4,5,6",1)/return_sum("2,3,4,5,6",0)
    puts collect_percent
    doc=Collection.find_by_user_id(1).open_xml
    n=0
    percent=0
    doc.elements["/collection/problems"].each_element do |problem|
      problem.elements["questions"].each_element do |question|
        percent +=question.attributes["correct_percent"].split("%")[0].to_f/100 unless question.attributes["correct_percent"].nil?
        n +=1
      end
    end
    incorrect_percent=percent/n
    puts incorrect_percent
    sum=simulation_belief*0.5*(old_percent*0.3+ collect_percent*0.5+incorrect_percent*0.2)
    puts sum
    user.belief=(sum*100).to_i
    user.save
    puts (sum*100).to_i
  end



end
