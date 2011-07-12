class User < ActiveRecord::Base
  has_many :user_role_relations,:dependent=>:destroy
  has_many :roles,:through=>:user_role_relations,:foreign_key=>"role_id"
  has_many:examinations,:foreign_key=>"creater_id"
  has_many:papers, :foreign_key=>"creater_id"
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

end



