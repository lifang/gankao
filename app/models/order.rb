# encoding: utf-8
class Order< ActiveRecord::Base
  belongs_to :user

  TYPES={:english_fourth_level=>1,:english_sixth_level=>2}
  STATUS={:payed=>1}
  def self.serarch_tags(lists,tag)
    lists.elements["/collection/problems"].each_element do |problem|
      problem.elements["questions"].each_element do |question|
        unless question.elements["tags"].nil? or question.elements["tags"].text.nil?
          lists.elements["/collection/problems"].delete_element(question.xpath) unless question.elements["tags"].text.split(" ").include?(tag)
        else
          lists.elements["/collection/problems"].delete_element(question.xpath)
        end
      end
      lists.elements["/collection/problems"].delete_element(problem.xpath) if problem.elements["questions"].elements.size==0
    end
    return lists

  end
end
