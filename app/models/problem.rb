#encoding: utf-8
class Problem < ActiveRecord::Base
  has_one:problem_tag
  belongs_to:category
  has_many:problem_tag_relations,:dependent=>:destroy
  has_many :tags,:through=>:problem_tag_relations,:foreign_key=>"tag_id"
  has_many:questions,:dependent=>:destroy

  require 'rexml/document'
  include REXML
  
  QUESTION_TYPE = {:SINGLE_CHOSE => 0, :MORE_CHOSE =>1, :JUDGE => 2, :SINGLE_CALK => 3,
    :COLLIGATION => 4, :CHARACTER => 5, :MORE_BLANKS => 6  }
  #0 单选题； 1 多选题；2 判断题；3 填空题； 4 综合题； 5 简答题； 6 多选选择题

  #创建problem
  def Problem.create_problem(paper, options = {})
    options[:category_id] = paper.category_id
    return Problem.create(options)
  end

  #打开xml
  def self.open_xml(url)
    return Document.new(url)
  end





  
end



