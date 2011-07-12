class Examination < ActiveRecord::Base
  has_many :examination_paper_relations,:dependent => :destroy
  has_many :papers,:through=>:examination_paper_relations, :source => :paper
  has_many :score_levels,:dependent=>:destroy
  belongs_to :user,:foreign_key=>"creater_id"
  has_many :exam_users,:dependent => :destroy
  has_many :exam_raters,:dependent => :destroy

  STATUS = {:EXAMING => 0, :LOCK => 1, :GOING => 2,  :CLOSED => 3 } #考试的状态：0 考试中 1 未开始 2 进行中 3 已结束
  IS_PUBLISHED = {:NEVER => 0, :ALREADY => 1} #是否发布  0 没有 1 已经发布

  default_scope :order => "examinations.created_at desc"



end
