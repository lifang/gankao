#encoding: utf-8
class ExamListsController < ApplicationController
  before_filter :access?
  layout "gankao"
  def  list
    collection = Collection.find_by_user_id(cookies[:user_id])
    lists = collection.open_xml if collection and collection.collection_url
    lists.elements["/collection/problems"].each_element do |problem|
      problem.elements["questions"].each_element do |question|
        lists.elements["/collection/problems"].delete_element(question.xpath) unless question.attributes["delete_status"].nil?
      end
      lists.elements["/collection/problems"].delete_element(problem.xpath) unless  problem.attributes["delete_status"].nil?
    end if lists
    return lists
  end
  
  def simulate_list
    @examination_lists = Examination.where("types = ? and is_published = ? and category_id = ?",
      Examination::TYPES[:SIMULATION], Examination::IS_PUBLISHED[:ALREADY], params[:id].to_i)
    examinations = Examination.find_by_sql("select e.id from examinations e inner join exam_users u on u.examination_id = e.id
          where e.category_id = #{params[:id].to_i} and  e.types = #{Examination::TYPES[:SIMULATION]}
          and e.is_published = #{Examination::IS_PUBLISHED[:ALREADY]} and u.user_id = #{cookies[:user_id].to_i} ")
    @examination_lists.each do |examination|
      @examination_lists -=[examination] unless examinations.include?(examination.id) if examination.status == Examination::STATUS[:CLOSED]
    end
    @hash = Examination.exam_users_paper(cookies[:user_id].to_i, Examination::TYPES[:SIMULATION], params[:id].to_i)
  end
  
  def old_exam_list
    @old_lists = Examination.where("types = ? and is_published = ? and category_id=?",
      Examination::TYPES[:OLD_EXAM], Examination::IS_PUBLISHED[:ALREADY],params[:id])
    @hash = Examination.exam_users_hash(cookies[:user_id].to_i, Examination::TYPES[:OLD_EXAM],params[:id])
  end
  
  def incorrect_list
    session[:tag] = nil
    @hash_list = {}
    @has_next_page = false
    @lists = list
    if @lists
      @num = @lists.get_elements("//problems/problem").size
      tags = @lists.get_elements("//problems//questions//tags")
      @tags = []
      tags.each do |tag|
        @tags = @tags | tag.text.split(" ") unless tag.nil? or tag.text.nil? or tag.text == ""
      end
      @lists = Examination.get_start_element(params[:page], @lists)
      current_element = Examination.return_page_element(@lists, @has_next_page)
      @lists = current_element[0]
      problem = @lists.elements["/collection/problems/problem/questions"]
      problem.each_element do |question|
        @hash_list["#{question.attributes['id']}"] = Feedback.find_all_by_user_id_and_question_id(cookies[:user_id], question.attributes["id"].to_i)
      end unless problem.nil?
      @has_next_page = current_element[1]
    end
  end


  def feedback
    @feedback=Feedback.create(:description => params[:description],
      :user_id => cookies[:user_id].to_i, :question_id => params[:question_id].to_i)
    @hash_list ={}
    @hash_list["#{params[:question_id]}"] = Feedback.
      find_all_by_user_id_and_question_id(cookies[:user_id].to_i, params[:question_id].to_i)
    doc = Collection.find_by_user_id(cookies[:user_id]).open_xml
    problem = doc.elements["/collection/problems/problem[@id='#{params[:problem_id]}']"]
    question = problem.elements["questions/question[@id='#{params[:question_id]}']"]
    render :partial => "/exam_lists/feedback",:object=>[question, problem]
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
  end

  def compare_answer
    problem_id = params[:problem_id]
    collection = Collection.find_by_user_id(cookies[:user_id].to_s)
    doc = collection.open_xml
    problem = doc.elements["/collection/problems/problem[@id='#{problem_id}']"]
    problem.elements["questions"].each_element do |question|
      id = question.attributes["id"]
      true_num = (((question.attributes["error_percent"].to_f)/100) * (question.attributes["repeat_num"].to_i)).round
      if params["answer_#{id}"]== question.elements["answer"].text.strip
        true_num += 1
      end
      question.add_element("user_answer").add_text(params["answer_#{id}"])
      question.attributes["repeat_num"] = question.attributes["repeat_num"].to_i + 1
      question.attributes["error_percent"] = ((true_num.to_f/(question.attributes["repeat_num"].to_i))*100).round
    end
    self.write_xml("#{Constant::PUBLIC_PATH}#{collection.collection_url}", doc)
    render :partial=>"/exam_lists/question_answer",:object=>list.elements["/collection/problems/problem[@id='#{problem_id}']"]
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
    flash[:notice] = "删除成功。"
    if params[:page].to_i>1
      redirect_to  "/exam_lists/#{params[:id]}/incorrect_list?page=#{params[:page].to_i-1}"
    else
      redirect_to  "/exam_lists/#{params[:id]}/incorrect_list"
    end
  end

  def load_note
    note_text = ""
    @problem_id=params[:problem_id]
    note = Note.find_by_user_id(cookies["user_id"].to_i)
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
    collection_question.add_element("created_at").add_text("#{Time.now.strftime("%Y-%m-%d %H:%M")}")
    if problem
      question = note.question_in_note(problem, params[:id])
      if question
        note.update_question(params["note_text_#{params[:id]}"].strip, question.xpath, note_doc)
      else
        problem.elements["questions"].add_element(collection_question)
        note.save_xml(note_doc)
      end
    else
      collection_problem.elements["questions"].each_element do |question|
        collection_problem.delete_element(question.xpath) if question.attributes["id"].to_i != params[:id].to_i
      end if collection_problem
      note_doc.elements["note/problems"].add_element(collection_problem)
      note.save_xml(note_doc)
    end
    flash[:notice] = "笔记添加成功."
    render :update do |page|
      page.replace_html "note_div" , :partial => "/common/flash_div"
      page.replace_html "biji_tab" , :inline => "<script>document.getElementById('note_area').style.display='none';</script>"
    end
  end

  def search_tag_problems
    session[:tag]=params[:tag]
    redirect_to "/exam_lists/#{params[:id]}/search_tag"
  end

  def search_tag
    @hash_list = {}
    @has_next_page = false
    @lists =list
    if @lists
      tags = @lists.get_elements("//problems//questions//tags")
      @tags = []
      tags.each do |tag|
        @tags = @tags | tag.text.split(" ") unless tag.nil? or tag.text.nil? or tag.text == ""
      end
      @lists=Order.serarch_tags(@lists,session[:tag])
      @num = @lists.get_elements("//problems/problem").size
      @lists = Examination.get_start_element(params[:page], @lists)
      current_element = Examination.return_page_element(@lists, @has_next_page)
      @lists = current_element[0]
      @has_next_page = current_element[1]
      problem = @lists.elements["/collection/problems/problem/questions"]
      problem.each_element do |question|
        @hash_list["#{question.attributes['id']}"] = Feedback.find_all_by_user_id_and_question_id(cookies[:user_id], question.attributes["id"].to_i)
      end unless problem.nil?
    end
    render "/exam_lists/incorrect_list"
  end

  #模拟考试宣传框，点击“不再显示”复选框触发
  def ajax_hide_exercise    
    if params['control']=="hide"
      cookies["hide_exercise#{cookies[:user_id]}"]={:value => "hide", :expires => Time.now+7.days, :path => "/", :secure => false}
    else
      cookies["hide_exercise#{cookies[:user_id]}"]="show"
    end
    render :inline=>""
  end

end
