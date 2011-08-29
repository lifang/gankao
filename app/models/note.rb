#encoding: utf-8
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
  def update_question(note_text, question_xpath, note_doc)
    que = note_doc.elements[question_xpath]
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
    user_answer = (question_answer and question_answer.text) ? question_answer.text : ""
    paper_question.add_element("user_answer").add_text("#{user_answer}")
    paper_question.add_element("note_text").add_text("#{note_text}")
    questions.elements.add(paper_question)
    self.save_xml(note_doc)
  end

  #如果当前题目没有做过笔记，则将题目加入到笔记
  def add_problem(question_id, paper_url, question_answer, note_text, problem_path, note_doc)
    paper = ExamRater.open_file("#{Constant::BACK_PUBLIC_PATH}#{paper_url}")
    paper_problem = paper.elements["#{problem_path}"]
    paper_problem.elements["questions"].each_element do |question|
      paper.delete_element(question.xpath) if question.attributes["id"].to_i != question_id.to_i
    end if paper_problem
    last_question = paper_problem.elements["questions"].elements["question[@id='#{question_id.to_i}']"]
    user_answer = (question_answer and question_answer.text) ? question_answer.text : ""
    last_question.add_element("user_answer").add_text("#{user_answer}")
    last_question.add_element("note_text").add_text("#{note_text}")
    note_doc.elements["/note/problems"].elements.add(paper_problem)
    self.save_xml(note_doc)
  end

  #查询试题
  def search(doc, note_text)
    doc.root.elements["problems"].each_element do |problem|
      problem.elements["questions"].each_element do |question|
        doc.delete_element(question.xpath) unless question.elements["note_text"].text =~ /#{note_text}/
      end
    end unless note_text.nil? or note_text == ""
    return doc
  end

  #返回开始显示的节点
  def get_start_element(page, doc)
    start_num = (page.nil? or page == "" or page == "1") ? 0 : (page.to_i-1) * 1
    doc.root.elements['problems'].each_element do |problem|
      problem.elements["questions"].each_element do |question|
        doc.delete_element(question.xpath) if start_num > 0
        start_num -= 1
      end
    end if start_num > 0
    return doc
  end

  #返回所有要显示的节点
  def return_page_element(doc, has_next_page)
    current_num = 0
    doc.elements["note"].elements['problems'].each_element do |problem|
      problem.elements["questions"].each_element do |question|
        if current_num >= 1
          doc.delete_element(question.xpath)
          has_next_page = true unless has_next_page
        end
        current_num += 1
      end
    end
    return [doc, has_next_page]
  end

end
