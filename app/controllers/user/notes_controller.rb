#encoding: utf-8
class User::NotesController < ApplicationController
  layout "gankao", :except => ["load_note", "create_note"]
  before_filter :access?

  def show
    session[:tag] = nil
    @note = Note.find_by_user_id(cookies[:user_id])
    begin
      pre_page = 10
      @has_next_page = false
      @doc = @note.open_xml
      @total_page = @note.return_total_page(@doc, pre_page)
      @doc = @note.get_start_element(params[:page], @doc, pre_page)
      current_element = @note.return_page_element(@doc, @has_next_page, pre_page)
      @doc = current_element[0]
      @has_next_page = current_element[1]
    rescue
      flash[:warn] = "您当前未做任何笔记。"
    end
  end

  def load_note
    note_text = ""
    exam_user = ExamUser.is_exam_user_in(params[:paper_id].to_i, params[:examination_id].to_i, cookies[:user_id].to_i)
    if exam_user
      note = Note.find_by_user_id(exam_user.user_id)
      if note and note.note_url
        note_text = note.return_note_text(params[:problem_id], params[:id])
      end
    end
    render :partial => "/user/notes/show_note_div", :object => [note_text, params[:id]]
  end

  def create_note
    exam_user = ExamUser.is_exam_user_in(params[:paper_id].to_i, params[:examination_id].to_i, cookies[:user_id].to_i)
    if exam_user
      note = Note.find_or_create_by_user_id(exam_user.user_id)
      note.set_note_url
      question_answer = exam_user.return_question_answer(params[:id])
      note_doc = note.open_xml
      problem = note.problem_in_note(params[:problem_id], note_doc)
      if problem
        question = note.question_in_note(problem, params[:id])
        if question
          note.update_question(params["note_text_#{params[:id]}"].strip, question.xpath, note_doc)
        else
          note.add_question(exam_user.paper_url, question_answer, params["note_text_#{params[:id]}"].strip,
            params[:question_path], problem, note_doc)
        end
      else
        note.add_problem(params[:id], exam_user.paper_url, question_answer, params["note_text_#{params[:id]}"].strip,
          params[:problem_path], note_doc)
      end
    end
    flash[:notice] = "笔记添加成功."
    render :update do |page|
      page.replace_html "note_div" , :partial => "/common/flash_div"
      page.replace_html "biji_tab" , :inline => "<script>document.getElementById('note_area').style.display='none';</script>"
    end
  end

  def update_note
    note = Note.find_by_user_id(cookies[:user_id].to_i)
    note.update_question(params["note_text_#{params[:id]}"].strip, 
      params["q_xpath_#{params[:id]}"], note.open_xml) if note
    flash[:notice] = "笔记编辑成功。"
    redirect_to "/user/notes/#{params["category_id_" + params[:id]]}"
  end

  def search
    session[:note_text] = params[:note_text]
    redirect_to "/user/notes/#{params[:id]}/search_list"
  end

  def search_list
    pre_page = 10
    @note = Note.find_by_user_id(cookies[:user_id].to_i)
    @doc = @note.search(@note.open_xml, session[:note_text])
    @total_page = @note.return_total_page(@doc, pre_page)
    @has_next_page = false
    @doc = @note.get_start_element(params[:page], @doc, pre_page)
    current_element = @note.return_page_element(@doc, @has_next_page, pre_page)
    @doc = current_element[0]
    @has_next_page = current_element[1]
    render "show"
  end

  

end
