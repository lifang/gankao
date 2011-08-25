class User < ActiveRecord::Base
  has_many :user_role_relations,:dependent=>:destroy
  has_many :roles,:through=>:user_role_relations,:foreign_key=>"role_id"
  has_many:examinations,:foreign_key=>"creater_id"
  has_many:papers, :foreign_key=>"creater_id"
  has_many:feedbacks
  default_scope :order=>'users.created_at desc'
  #email_regex=/\A[\w+\.]+@[a-z\d\-.]+\.[a-z]+\z/i
	#name_regex=/[a-zA-Z]{1,20}|[\u4e00-\u9fa5]{1,10}/

	#telephone_regex=/^[1-9]\d*$/
  attr_accessor :password,:old_password
  #	attr_accessible :name,:username,:mobilephone,:address,:email,:password,:password_confirmation,:status
  #	validates:name,  :presence=>true,:format=>{:with=>name_regex},:length=>{:maximum=>30}
  #	validates:email,  :presence=>true,:uniqueness =>true,:format=>{:with=>email_regex},:length=>{:maximum=>50}
  validates:password, :confirmation=>true,:length=>{:within=>6..20}, :allow_nil => true

  STATUS = {:LOCK => 0, :NORMAL => 1} #0 未激活用户  1 已激活用户

  DEFAULT_PASSWORD = "123456"

	def right_password?(varnum)
    self.encrypted_password==encrypt(varnum)
  end

  #创建用户权限
  def set_role(role)
    roles << role
  end

  def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end

  def self.authenticate(username, submitted_password)
    user = find_by_username(username)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end


  def encrypt_password
    self.encrypted_password=encrypt(password)
  end

  #考试组织人员添加考生自动添加账号
  def self.auto_add_user(name, username, email, mobilephone)
    user = User.new(:name => name, :username => username, :email => email,
      :mobilephone => mobilephone,:password => DEFAULT_PASSWORD,:password_confirmation => DEFAULT_PASSWORD)
    user.set_role(Role.find(Role::TYPES[:STUDENT]))
    user.status = User::STATUS[:NORMAL]
    user.encrypt_password
    user.save!
    return user
  end

  def User.calculation_confidence(id)
    user =User.find(id)
    simulation_belief=0
    num=return_sum(Examination::TYPES[:SIMULATION],1,id).to_i
    simulation_belief=0.5 if num >=1
    simulation_belief=0.8 if num>=2
    simulation_belief=1 if num>=3
    puts simulation_belief
    old_percent=return_sum(Examination::TYPES[:OLD_EXAM],1,id)/return_sum(Examination::TYPES[:OLD_EXAM],0,id)
    puts 4.0/7
    puts old_percent
    collect_percent=return_sum("2,3,4,5,6",1,id)/return_sum("2,3,4,5,6",0,id)
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
    return (sum*100).to_i
end
   def self.return_sum(types,user,id)
      sql="select count(e.id) sum from examinations  e left join exam_users u on u.examination_id=e.id where 1=1"
      if types.to_s.length==1
        sql += " and e.types=#{types}"
      else
        sql += " and e.types in (#{types})"
      end
      sql += " and u.user_id=#{id}" if user==1
      return ExamUser.find_by_sql(sql)[0].sum*1.0
    end

private
def encrypt(string)
  self.salt = make_salt if new_record?
  secure_hash("#{salt}--#{string}")
end

def make_salt
  secure_hash("#{Time.new.utc}--#{password}")
end

def secure_hash(string)
  Digest::SHA2.hexdigest(string)
end

end



