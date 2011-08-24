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
    return Document.new(File.open(dir + self.note_url))
  end

  def save_xml(doc)
    url = Constant::PUBLIC_PATH + self.note_url
    f=File.new(url,"w")
    f.write("#{doc.to_s.force_encoding('UTF-8')}")
    f.close
  end

  #当前题目是否已经做过笔记
  def problem_in_note(problem_id, note_doc)
    problem = note_doc.elements["note"].elements["problems"].elements["problem[@id='#{problem_id}']"]
    return problem
  end

  #当前题点是否已经做过笔记
  def question_in_note(problem, question_id)
    question = problem.elements["questions"].elements["question[@id='#{question_id}']"]
    return question
  end

  #返回题点的笔记
  def return_note_text(problem_id, question_id)
    note_text = ""
    note_xml = self.open_xml
    problem = note_xml.elements["note"].elements["problems"].elements["problem[@id='#{problem_id}']"]
    if problem.elements["questions"].elements["question[@id='#{question_id}']"]
      question_note = problem.elements["questions"].elements["question[@id='#{question_id}']"]
      note_text = question_note.elements["note_text"].text if question_note and
        question_note.elements["note_text"] and question_note.elements["note_text"].text
    end if problem
    return note_text
  end

  #如果题点已经做过笔记，则重新保存笔记
  def update_question(note_text, question, note_doc)
    que = note_doc.elements[question.xpath]
    if que.elements["note_text"]
      que.elements["note_text"].text = note_text
    else
      que.add_element("note_text").add_text("#{note_text}")
    end
    self.save_xml(note_doc)
  end

  #如果当前题目有题点已经做过笔记，就只增加题点
  def add_question(paper_url, question_answer, note_text, question_path, problem, note_doc)
    paper = ExamRater.open_file("#{Constant::BACK_PUBLIC_PATH}#{paper_url}")
    paper_question = paper.elements["#{question_path}"]
    questions = note_doc.elements["#{problem.xpath}/questions"]
    paper_question.add_element("user_answer").add_text("#{question_answer.text}")
    paper_question.add_element("note_text").add_text("#{note_text}")
    questions.elements.add(paper_question)
    self.save_xml(note_doc)
  end

  #如果当前题目没有做过笔记，则将题目加入到笔记
  def add_problem(question_id, paper_url, question_answer, note_text, problem_path, note_doc)
    paper = ExamRater.open_file("#{Constant::BACK_PUBLIC_PATH}#{paper_url}")
    paper_problem = paper.elements["#{problem_path}"]
    paper_problem.elements["questions"].each_element do |question|
      if question.attributes["id"].to_i != question_id.to_i
        paper.delete_element(question.xpath)
      end
    end if paper_problem
    last_question = paper_problem.elements["questions"].elements["question[@id='#{question_id.to_i}']"]
    last_question.add_element("user_answer").add_text("#{question_answer.text}")
    last_question.add_element("note_text").add_text("#{note_text}")
    note_doc.elements["/note/problems"].elements.add(paper_problem)
    self.save_xml(note_doc)
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
