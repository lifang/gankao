class ExamListsController < ApplicationController
  before_filter :access?
  def  list
    lists=Collection.find_by_user_id(cookies[:user_id]).open_xml
    lists.elements["/collection/problems"].each_element do |problem|
      problem.elements["questions"].each_element do |question|
        lists.elements["/collection/problems"].delete_element(question.xpath) unless question.attributes["delete_status"].nil?
      end
      lists.elements["/collection/problems"].delete_element(problem.xpath) unless  problem.attributes["delete_status"].nil?
    end
    return lists
  end
  
  def simulate_list
    @examination_lists=Examination.where("types=? and is_published=1",Examination::TYPES[:SIMULATION])
    examinations=Examination.find_by_sql("select e.id from examinations e inner join exam_users u on u.examination_id=e.id
                  where u.user_id=#{cookies[:user_id]} and e.status=#{Examination::STATUS[:CLOSED ]} and e.is_published=1 ")
    @examination_lists.each do |examination|
      @examination_lists -=[examination] unless examinations.include?(examination.id)  if examination.status==Examination::STATUS[:CLOSED ]
    end
    @hash=Examination.exam_users_hash(cookies[:user_id],Examination::TYPES[:SIMULATION])
    render :layout=>"gankao"
  end
  
  def old_exam_list
    @old_lists=Examination.where("types=? and is_published=1",Examination::TYPES[:OLD_EXAM])
    @hash=Examination.exam_users_hash(cookies[:user_id],Examination::TYPES[:OLD_EXAM])
    render :layout=>"gankao"
  end
  
  def incorrect_list
    @hash_list={}
    @has_next_page = false
    @lists=list
    @num=@lists.get_elements("//problems/problem").size
    @lists =Examination.get_start_element(params[:page], @lists)
    current_element = Examination.return_page_element(@lists, @has_next_page)
    @lists = current_element[0]
    problem=@lists.elements["/collection/problems/problem/questions"]
    problem.each_element do |question|
      @hash_list["#{question.attributes['id']}"]=Feedback.find_all_by_user_id_and_question_id(cookies[:user_id],question.attributes["id"].to_i)
    end unless problem.nil?
    @has_next_page = current_element[1]
    render :layout=>"gankao"
  end


  def feedback
    @feedback=Feedback.create(:description=>params[:description],:user_id=>"#{cookies[:user_id]}",:question_id=>params[:question_id])
    @hash_list={}
    @hash_list["#{params[:question_id]}"]=Feedback.find_all_by_user_id_and_question_id(cookies[:user_id],params[:question_id])
    doc=Collection.find_by_user_id(cookies[:user_id]).open_xml
    problem=doc.elements["/collection/problems/problem[@id='#{params[:problem_id]}']"]
    question=problem.elements["questions/question[@id='#{params[:question_id]}']"]
    render :partial=>"/exam_lists/feedback",:object=>[question,problem]
  end


  def question_info
    @has_next_page = false
    @lists=list
    @num=@lists.get_elements("//problems/problem").size
    @lists =Examination.get_start_element(params[:page], @lists)
    current_element = Examination.return_page_element(@lists, @has_next_page)
    @lists = current_element[0]
    @problem=@lists.elements["/collection/problems/problem"]
    @has_next_page = current_element[1]
    render :layout=>"gankao"
  end

  def compare_answer
    problem_id=params[:problem_id]
    collection=Collection.find_by_user_id(cookies[:user_id])
    doc=collection.open_xml
    problem=doc.elements["/collection/problems/problem[@id='#{problem_id}']"]
    problem.elements["questions"].each_element do |question|
      id=question.attributes["id"]
      if params["answer_#{id}"]==question.elements["answer"].text
        correct_percent=1.0/(question.elements["user_answer"].size+1)*100
        question.attributes["error_percent"]=(100-correct_percent).to_i
      else
        question.add_element("user_answer").add_text(params["answer_#{id}"])
        problem.attributes["repeat_num"] =problem.attributes["repeat_num"].to_i+1
      end
    end
    self.write_xml("#{Constant::PUBLIC_PATH}#{collection.collection_url}", doc)
    doc=collection.open_xml
     @num=list.get_elements("//problems/problem").size
    @lists =problem
    @has_next_page =!doc.elements["/collection/problems/problem[@id='#{problem_id}']"].next_element.nil?
    render :partial=>"/exam_lists/question_answer"
  end
  
  def delete_problem
    collection=Collection.find_by_user_id(cookies[:user_id])
    doc=collection.open_xml
    problem=doc.elements["/collection/problems/problem[@id=#{params[:problem_id]}]"]
    problem.elements["questions/question[@id=#{params[:question_id]}]"].add_attribute("delete_status",1)
    n=0
    problem.elements["questions"].each_element do |question|
      n=1 if question.attributes["delete_status"].nil?
    end
    problem.add_attribute("delete_status",1) if n==0
    self.write_xml("#{Constant::PUBLIC_PATH}#{collection.collection_url}", doc)
    if params[:page].to_i>1
      redirect_to  "/exam_lists/incorrect_list?page=#{params[:page].to_i-1}"
    else
      redirect_to  "/exam_lists/incorrect_list"
    end
  end

  def load_note
    note_text = ""
    @problem_id=params[:problem_id]
    note = Note.find_by_user_id(cookies["user_id"])
    if note and note.note_url
      note_text = note.return_note_text(@problem_id, params[:id])
    end
    render :partial => "/exam_lists/note_div", :object => [note_text, params[:id]]
  end

  def create_note
    note = Note.find_or_create_by_user_id(cookies[:user_id])
    note.set_note_url
    note_doc = note.open_xml
    problem = note.problem_in_note(params[:problem_id], note_doc)
    doc=Collection.find_by_user_id(cookies[:user_id]).open_xml
    collection_problem=doc.elements["/collection/problems/problem[@id=#{params[:problem_id]}]"]
    collection_question=collection_problem.elements["questions/question[@id=#{params[:id]}]"]
    collection_question.add_element("note_text").add_text("#{params["note_text_#{params[:id]}"].strip}")
    if problem
      question = note.question_in_note(problem, params[:id])
      if question
        note.update_question(params["note_text_#{params[:id]}"].strip, question.xpath, note_doc)
      else
        problem.add_elements(collection_question)
        note.save_xml(note_doc)
      end
    else
      note_doc.elements["note/problems"].add_element(collection_problem)
      note.save_xml(note_doc)
    end
    flash[:notice] = "笔记添加成功."
    redirect_to request.referer
  end


end
