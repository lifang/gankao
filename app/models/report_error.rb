#encoding: utf-8
class ReportError < ActiveRecord::Base
  #1 题目错误； 2 答案错误；3 解析错误;
  ERROR_TYPE = {1=>"题目错误",2=>"答案错误",3=>"解析错误"}
  
end
