class User::CollectionsController < ApplicationController
  before_filter :access?
  
  def index
    session[:tag] = nil
    @collection = Collection.find_by_user_id(cookies[:user_id])
      begin
        @doc = @collection.open_xml
      rescue
        flash[:warn] = "您的收藏数据已清空。"
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
    render :partial => "/common/display_flash"
  end

  def search
    session[:tag] = params[:tag]
    @collection = Collection.find_by_user_id(cookies[:user_id])
    @doc = @collection.search(@collection.open_xml, params[:tag], params[:category])
    render "index"
  end
  
end
