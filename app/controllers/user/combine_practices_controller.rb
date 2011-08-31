class User::CombinePracticesController < ApplicationController
  layout "paper", :only => [:save_result]
  before_filter :access?
  

  def show
    
    @practice_type=params[:practice_type]
    Examination::TYPE_NAMETYPESS.each_value do |array|
      if array[0]==@practice_type.to_i
        @practice_name=array[1]
        break
      end
    end
    arr = ExamUser.can_answer(cookies[:user_id].to_i, params[:id].to_i)
    if arr[0] == "" and arr[1].any?
      @examination = arr[1][0]
      @exam_user = ExamUser.find_by_examination_id_and_user_id(@examination.id, cookies[:user_id].to_i)
      @exam_user = ExamUser.create(:user_id => cookies[:user_id],:examination_id => @examination.id,
        :password => User::DEFAULT_PASSWORD, :is_user_affiremed => ExamUser::IS_USER_AFFIREMED[:YES]) if @exam_user.nil?
      @exam_user.set_paper(@examination) if @exam_user.paper_id.nil?
      if @exam_user and @exam_user.paper_id
        @paper_url = "#{Constant::PAPER_CLIENT_PATH}/#{@exam_user.paper_id}.js"
        @exam_user.update_info_for_join_exam(@examination.start_at_time,
          @examination.exam_time) if @examination.started_at.nil? or @examination.started_at == ""
        render :layout => "application"
      else
        flash[:warn] = "试卷加载错误，请您重新尝试。"
        redirect_to "/user/examinations"
      end
    else
      flash[:warn] = arr[0]
      redirect_to request.referer
    end
  end

  def start
    @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id].to_i, cookies[:user_id].to_i)
    @exam_user = ExamUser.create(:user_id => cookies[:user_id],:examination_id => params[:id].to_i,
      :password => User::DEFAULT_PASSWORD, :is_user_affiremed => ExamUser::IS_USER_AFFIREMED[:YES]) if @exam_user.nil?
    arr = ExamUser.can_answer(cookies[:user_id], params[:id].to_i)
    if arr[0] == "" and arr[1].any?
      render :inline => "<iframe src='#{Constant::SERVER_PATH}/user/combine_practices/#{params[:id]}/?practice_type=#{params[:practice_type]}'
            frameborder='0' style='width: 1270px; height: 760px;'></iframe>"
    else
      flash[:warn] = arr[0]
      redirect_to request.referer
    end
  end

  def save_result
    @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id], cookies[:user_id])
    if @exam_user and (@exam_user.is_submited.nil? or @exam_user.is_submited == false)
      question_hash = {}
      question_ids = params[:all_quesiton_ids].split(",") if params[:all_quesiton_ids]
      question_ids.each do |question_id|
        question_hash[question_id] = [params["answer_" + question_id], "1"]
      end if question_ids
      @exam_user.auto_add(@exam_user,question_hash) if params[:types].to_i==Examination::TYPES[:OLD_EXAM]
      @exam_user.generate_answer_sheet_url(@exam_user.update_answer_url(@exam_user.open_xml, question_hash), "result")
      @exam_user.submited!
      flash[:notice] = "标准答案已给出，请检查。"
      redirect_to "/user/exam_users/#{@exam_user.examination_id}?user_id=#{cookies[:user_id]}"
    end
  end


end
