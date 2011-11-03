#encoding: utf-8
class User::CollectionsController < ApplicationController
  before_filter :access?
  
  def index
    session[:tag] = nil
    @collection = Collection.find_by_user_id(cookies[:user_id])
    begin
      @doc = @collection.open_xml
    rescue
      flash[:warn] = "您暂无收藏数据。"
    end
  end

  def create
    problem = params["problem_content_#{params[:problem_id]}"].strip
    exam_user = ExamUser.is_exam_user_in(params[:paper_id].to_i, params[:examination_id].to_i, cookies[:user_id].to_i)
    if exam_user
      collection = Collection.find_or_create_by_user_id(exam_user.user_id)
      collection.set_collection_url
      unless problem.nil? or problem == ""
        doc = collection.delete_problem(params[:problem_id].to_i, collection.open_xml)
        doc = collection.add_problem(doc, problem)
        collection.generate_collection_url(doc.to_s)
      end     
    end
    flash[:notice] = "收藏成功."
    render :partial => "/common/flash_div"
  end

  def search
    session[:tag] = params[:tag]
    @collection = Collection.find_by_user_id(cookies[:user_id])
    @doc = @collection.search(@collection.open_xml, params[:tag], params[:category])
    render "index"
  end

  def create_collection
    exam_user = ExamUser.is_exam_user_in(params[:paper_id].to_i, params[:examination_id].to_i, cookies[:user_id].to_i)
    if exam_user
      collection = Collection.find_or_create_by_user_id(exam_user.user_id)
      collection.set_collection_url
      question_answer = exam_user.return_question_answer(params[:id])
      collection_doc = collection.open_xml
      problem = collection.problem_in_collection(params[:problem_id], collection_doc)
      if problem
        question = collection.question_in_collection(problem, params[:id])
        if question
          if question.elements["tags"].nil?
            question.add_element("tags").add_text("我的关注")
          else
            question.elements["tags"].text="#{question.elements["tags"].text} 我的关注" unless question.elements["tags"].text =~ /我的关注/     
          end
          question.delete_attribute("delete_status") unless question.attributes["delete_status"].nil?
          problem.delete_attribute("delete_status") unless problem.attributes["delete_status"].nil?
          collection.generate_collection_url(collection_doc.to_s)
          flash[:warn] = "当前题目已经收藏成功。"
        else
          collection.hand_add_question(exam_user.paper_url, question_answer,
            params[:question_path], problem, collection_doc)
          flash[:notice] = "收藏成功。"
        end
      else
        collection.hand_add_problem(params[:id], exam_user.paper_url, question_answer, 
          params[:problem_path], collection_doc)
        flash[:notice] = "收藏成功。"
      end
    end
    render :partial => "/common/flash_div"
  end
  
end
