class User::NotesController < ApplicationController
  before_filter :access?

  def index
    session[:tag] = nil
    @note = Note.find_by_user_id(cookies[:user_id])
      begin
        @doc = @note.open_xml
      rescue
        flash[:warn] = "您当前未做任何笔记。"
      end
  end

  def create
    problem = params["problem_content_#{params[:problem_id]}"].strip
    exam_user = ExamUser.is_exam_user_in(params[:paper_id].to_i, params[:examination_id].to_i, cookies[:user_id].to_i)
    if exam_user
      note = Note.find_or_create_by_user_id(exam_user.user_id)
      note.set_note_url
      unless problem.nil? or problem == ""
        doc = note.delete_problem(params[:problem_id].to_i, note.open_xml)
        doc = note.add_problem(doc, problem)
        note.generate_note_url(doc.to_s)
      end
    end
    flash[:notice] = "笔记添加成功."
    render :partial => "/common/display_flash"
  end
  
end
