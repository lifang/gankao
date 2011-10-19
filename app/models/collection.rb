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

  #当前题目是否已经收藏到错题集
  def problem_in_collection(problem_id, collection_doc)
    problem = collection_doc.elements["collection"].elements["problems"].elements["problem[@id='#{problem_id}']"]
    return problem
  end

  #当前题点是否已经收藏到错题集
  def question_in_collection(problem, question_id)
    question = problem.elements["questions"].elements["question[@id='#{question_id}']"]
    return question
  end

  #更新当前提点的答案
  def update_question(answer_text, question_path, collection_xml)
    que = collection_xml.elements[question_path]
    if que.elements["user_answer"]
      true_num = (((que.attributes["error_percent"].to_i.to_f)/100) * (que.attributes["repeat_num"].to_i)).round
      que.attributes["repeat_num"] = que.attributes["repeat_num"].to_i + 1
      que.attributes["error_percent"] = ((true_num.to_f/(que.attributes["repeat_num"].to_i))*100).round
    else
      que.add_attribute("repeat_num", "1")
      que.add_attribute("error_percent", "0")
    end
    que.add_element("user_answer").add_text("#{answer_text}")
    self.generate_collection_url(collection_xml.to_s)
  end

  #如果当前题目有题点已经收藏过，就只收藏题点
  def add_question(question, answer_text, collection_problem, collection_xml)
    question.elements["tags"].text="#{question.elements["tags"].text}" unless question.elements["tags"].nil?
    question.add_element("user_answer").add_text("#{answer_text}")
    question.add_attribute("repeat_num", "1")
    question.add_attribute("error_percent", "0")
    questions = collection_xml.elements["#{collection_problem.xpath}/questions"]
    questions.elements.add(question)
    self.generate_collection_url(collection_xml.to_s)
  end

  #如果当前题目没有做过笔记，则将题目加入到笔记
  def auto_add_problem(paper_xml, question_id, problem_path, answer_text, collection_xml)
    paper_problem = paper_xml.elements["#{problem_path}"]
    paper_problem.elements["questions"].each_element do |question|
      if question.attributes["id"].to_i != question_id.to_i
        paper_xml.delete_element(question.xpath)
      end
    end if paper_problem
    block = paper_xml.elements["#{problem_path.split("/problems")[0]}/base_info/description"]
    unless block.nil?
      mp3 = block.text
      if mp3 != nil and mp3 =~ /<mp3>/
        unless paper_problem.elements["title"].nil?
          if paper_problem.elements["title"].text.nil?
            paper_problem.elements["title"].text="<mp3>#{mp3.split("<mp3>")[1]}<mp3>"
          else
            paper_problem.elements["title"].text="#{paper_problem.elements["title"].text} <mp3>#{mp3.split("<mp3>")[1]}<mp3>"
          end
        else
          paper_problem.add_element("title").add_text("<mp3>#{mp3.split("<mp3>")[1]}<mp3>")
        end
      end
    end
    last_question = paper_problem.elements["questions"].elements["question[@id='#{question_id.to_i}']"]
    last_question.elements["tags"].text="#{last_question.elements["tags"].text}" unless last_question.elements["tags"].nil?
    last_question.add_element("user_answer").add_text("#{answer_text}")
    last_question.add_attribute("repeat_num", "1")
    last_question.add_attribute("error_percent", "0")
    collection_xml.elements["/collection/problems"].elements.add(paper_problem)
    self.generate_collection_url(collection_xml.to_s)
  end

  #手动添加收藏提点
  def hand_add_question(paper_url, question_answer, question_path, problem, collection_doc)
    paper = ExamRater.open_file("#{Constant::BACK_PUBLIC_PATH}#{paper_url}")
    paper_question = paper.elements["#{question_path}"]
    paper_question.elements["tags"].text="#{paper_question.elements["tags"].text} 我的关注" unless paper_question.elements["tags"].nil?
    add_question(paper_question, question_answer.text, problem, collection_doc)
  end

  #手动添加收藏提点
  def hand_add_problem(question_id, paper_url, question_answer, problem_path, collection_doc)
    paper_xml = ExamRater.open_file("#{Constant::BACK_PUBLIC_PATH}#{paper_url}")
    paper_problem = paper_xml.elements["#{problem_path}"]
    paper_problem.elements["questions"].each_element do |question|
      question.elements["tags"].text="#{question.elements["tags"].text} 我的关注" unless question.elements["tags"].nil?
    end
    answer=question_answer.nil? ? "": question_answer.text
    auto_add_problem(paper_xml, question_id, problem_path, answer, collection_doc)
  end

end
