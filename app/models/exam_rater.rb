class ExamRater < ActiveRecord::Base
  require 'rexml/document'
  include REXML
  has_many :rater_user_relations,:dependent => :destroy
  has_many :exam_users, :through=>:rater_user_relations, :foreign_key => "exam_user_id"
  belongs_to :examination
  #
  #  email_regex=/\A[\w+\.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #	name_regex=/[a-zA-Z]{1,20}|[\u4e00-\u9fa5]{1,10}/
  #	#mobilephone_regex=/^[1-9]\d*$/
  #
  #  validates :name,:presence=>true,:format=>{:with=>name_regex},:length=>{:maximum=>30}
  #  validates :email,:presence=>true,:uniqueness=>true,:format=>{:with=>email_regex},:length=>{:maximum=>50}
  #打开xml文件
  def ExamRater.open_file(url)
    file=File.open("#{Rails.root}/public"+url)
    return Document.new(file).root
  end


 #批量检查阅卷老师信息
  def self.check_rater(info,id)
    rater_info=""
    hash =ExamUser.get_email(info)
    raters = ExamRater.find_by_sql(["select * from exam_raters r where r.email in (?) and r.examination_id=#{id}",hash.keys])
    if raters
      raters.each do |rater|
        rater_info += rater.name + "," + rater.email + ";"
      end
    end
    return rater_info
  end
  
  #批量创建阅卷老师
  def self.create_raters(info,examination)
    hash =ExamUser.get_email(info)
    chars = (1..9).to_a
    code_array = []
    hash.each do |email|
      1.upto(6) {code_array << chars[rand(chars.length)]}
      exam_rater=ExamRater.create(:examination_id =>examination.id , :name =>email[1][0],
        :mobilephone =>email[1][1].strip, :email =>email[0].strip, :author_code =>code_array.join(""))

      UserMailer.rater_affirm(exam_rater,examination).deliver
    end
  end
  def self.rater(doc,id)
    unless doc.elements[1].elements["auto_score"].nil?
      auto_score=doc.elements[1].elements["auto_score"].text
      if auto_score.to_i !=0
        doc.elements[1].attributes["score"]=score+auto_score.to_i
        ExamUser.find(id).update_attributes(:total_score=>score+auto_score.to_i)
      end
    end
    puts doc
    return doc.to_s
  end

end
