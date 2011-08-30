class ExamListsController < ApplicationController


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
    @examination_lists=Examination.where("types=?",Examination::TYPES[:SIMULATION])
    examnation_ids=@examination_lists.map(&:id).join(",")
    @hash=Examination.exam_users_hash(cookies[:user_id],examnation_ids)
  end
  
  def old_exam_list
    @old_lists=Examination.where("types=?",Examination::TYPES[:OLD_EXAM])
    examnation_ids=@old_lists.map(&:id).join(",")
    @hash=Examination.exam_users_hash(cookies[:user_id],examnation_ids)
  end

  def incorrect_list
    @has_next_page = false
    @lists=list
    @lists =Examination.get_start_element(params[:page], @lists)
    current_element = Examination.return_page_element(@lists, @has_next_page)
    @lists = current_element[0]
    @has_next_page = current_element[1]
    
  end

  def feedback_list
    @id=params[:id]
    @feedbacks=Feedback.find_all_by_user_id_and_question_id(cookies[:user_id],params[:id])
    render :partial=>"/exam_lists/feedback"
  end

  def feedback
    @feedback=Feedback.create(:description=>params[:feedback][:description],:user_id=>"#{cookies[:user_id]}",:question_id=>params[:id])
    redirect_to "/exam_lists/incorrect_list"
  end


  def question_info
    @has_next_page = false
    @lists=list
    @lists =Examination.get_start_element(params[:page], @lists)
    current_element = Examination.return_page_element(@lists, @has_next_page)
    @lists = current_element[0]
    @has_next_page = current_element[1]
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
        question.add_attribute("correct_percent","#{correct_percent.to_i}%")
      else
        question.add_element("user_answer").add_text(params["answer_#{id}"])
        problem.attributes["incorrect_num"] =problem.attributes["incorrect_num"].to_i+1
      end
    end
    self.write_xml("#{Constant::PUBLIC_PATH}#{collection.collection_url}", doc)
    doc=collection.open_xml
    @lists=doc.elements["/collection/problems/problem[@id='#{problem_id}']"]
    @lists =Examination.get_start_element(params[:page], @lists)
    current_element = Examination.return_page_element(@lists, @has_next_page)
    @lists = current_element[0]
    @has_next_page = current_element[1]
    render :partial=>"/exam_lists/question_answer",:object=>@xml
  end
  
  def delete_problem
    collection=Collection.find_by_user_id(cookies[:user_id])
    doc=collection.open_xml
    doc.elements["/collection/problems/problem[@id=#{params[:problem_id]}]/questions/question[@id=#{params[:question_id]}]"].
      add_attribute("delete_status",1)
    n=0
    doc.elements["/collection/problems/problem[@id=#{params[:problem_id]}]/questions"].each_element do |question|
      n=1 if question.attributes["delete_status"].nil?
    end
    doc.elements["/collection/problems/problem[@id=#{params[:problem_id]}]"].add_attribute("delete_status",1) if n==0
    self.write_xml("#{Constant::PUBLIC_PATH}#{collection.collection_url}", doc)
    @has_next_page = false
    @lists=list
    @lists =Examination.get_start_element(params[:page], @lists)
    current_element = Examination.return_page_element(@lists, @has_next_page)
    @lists = current_element[0]
    @has_next_page = current_element[1]
    @feedbacks=Feedback.find_by_sql("select * from feedbacks where user_id=#{cookies[:user_id]}")
    render "/exam_lists/incorrect_list"
  end



end
