# encoding: utf-8
class Collection < ActiveRecord::Base

  require 'rexml/document'
  include REXML
  COLLECTION_PATH = "/collections"

  def set_collection_url
    if self.collection_url.nil?
      self.collection_url = self.generate_collection_url(self.generate_collection_xml)
      self.save
    end
  end

  #创建收藏文件
  def generate_collection_url(str)
    dir = "#{Rails.root}/public" + COLLECTION_PATH
    unless File.directory?(dir)
      Dir.mkdir(dir)
    end
    file_name = "/#{self.id}.xml"
    url = dir + file_name
    f=File.new(url,"w")
    f.write("#{str.force_encoding('UTF-8')}")
    f.close
    return COLLECTION_PATH + file_name
  end

  #生成收藏的初始xml文件
  def generate_collection_xml
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    content += <<-XML
      <collection id='#{self.id}'>
        <problems></problems>
      </collection>
    XML
    return content
  end

  def open_xml
    dir = "#{Rails.root}/public"
    return Document.new(File.open(dir + self.collection_url))
  end

  #添加题目xml
  def add_problem(doc, problem_xml)
    str = doc.to_s.split("<problems/>")
    if doc.elements["collection"].elements["problems"].children.blank?
      doc = str[0] + "<problems>" + problem_xml + "</problems>" + str[1]
    else
      str = doc.to_s.split("</problems>")
      doc = str[0] + problem_xml + "</problems>" + str[1] if str[1]
    end
    return doc
  end

  #删除试题
  def delete_problem(problem_id, doc)
    puts "==================="
    puts doc.elements["/collection/problems/problem[@id='#{problem_id}']"].nil?
    puts doc.elements["/collection/problems/problem[@id='#{problem_id}']"].to_s
    doc.delete_element("/collection/problems/problem[@id='#{problem_id}']") if doc.elements["/collection/problems/problem[@id='#{problem_id}']"]
    return doc
  end

  #查询试题
  def search(doc, tag, category)
    doc.root.elements["problems"].each_element do |problem|
      if problem.elements["category"].text.to_i != category.to_i
        doc.delete_element(problem.xpath)
      end
    end unless category.nil? or category == ""
    unless tag.nil? or tag == ""
      tags = tag.strip.split(" ")
      doc.root.elements["problems"].each_element do |problem|
        is_include = false
        problem.elements["questions"].each_element do |question|
          if !question.elements["tags"].nil? and !question.elements["tags"].text.nil? and question.elements["tags"].text != ""
            question_tag = question.elements["tags"].text.split(" ")
            tags.each { |t| is_include = true  if question_tag.include?(t) }
          end
          break if is_include
        end
       if is_include == false
         doc.delete_element(problem.xpath)
       end
      end
    end
    return doc
  end

end
