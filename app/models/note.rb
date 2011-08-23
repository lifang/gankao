class Note < ActiveRecord::Base
  require 'rexml/document'
  include REXML
  NOTE_PATH = "/notes"

  def set_note_url
    if self.note_url.nil?
      self.note_url = self.generate_note_url(self.generate_note_xml)
      self.save
    end
  end

  #创建收藏文件
  def generate_note_url(str)
    dir = "#{Rails.root}/public" + NOTE_PATH
    unless File.directory?(dir)
      Dir.mkdir(dir)
    end
    file_name = "/#{self.id}.xml"
    url = dir + file_name
    f=File.new(url,"w")
    f.write("#{str.force_encoding('UTF-8')}")
    f.close
    return NOTE_PATH + file_name
  end

  #生成收藏的初始xml文件
  def generate_note_xml
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    content += <<-XML
      <note id='#{self.id}'>
        <problems></problems>
      </note>
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
