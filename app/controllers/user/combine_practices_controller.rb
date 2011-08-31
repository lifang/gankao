class User::CombinePracticesController < ApplicationController
  layout "paper", :only => [:do_exam, :save_result]
  before_filter :access?
  

  def show2
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

  def show3
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

  def show4
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

  def show5
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

  def show6
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
      render :inline => "<iframe src='#{Constant::SERVER_PATH}/user/combine_practices/#{params[:id]}/show#{params[:practice_type]}'
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


  def five_min_save
    unless params[:arr].nil? or params[:arr] == ""
      @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id], cookies[:user_id])
      questions = params[:arr].split(",")
      question_hash = {}
      0.step(questions.length-1, 3) do |i|
        question_hash[questions[i]] = [questions[i+1], questions[i+2]]
      end if questions.any?
      str=@exam_user.update_answer_url(@exam_user.open_xml, question_hash)
      @exam_user.generate_answer_sheet_url(str, "result")
    end
    render :text => ""
  end

  def enter_password
    render :layout => "application"
  end

  def check_exam_pwd
    can_show_paper = false
    if params[:exam_password]
      @examination = Examination.select("exam_password1, exam_password2").find(params[:id].to_i)
      @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id].to_i, cookies[:user_id].to_i)
      if @exam_user.nil? or
          (@exam_user and (@exam_user.answer_sheet_url.nil? and params[:exam_password] == @examination.exam_password1) or
            (@exam_user.answer_sheet_url and params[:exam_password] == @examination.exam_password2))
        can_show_paper = true
      end if @examination
    end
    if can_show_paper
      redirect_to "/user/examinations/#{params[:id]}/do_exam"
    else
      flash[:warn] = "您输入的验证码不正确。"
      redirect_to "/user/examinations/#{params[:id]}/enter_password"
    end
  end

  def start_fixup_time
    start_time = ""
    block = PaperBlock.find(params[:id].to_i)
    unless block.time.nil? or block.time == ""
      if block.start_time.nil? or block.start_time == ""
        block.start_time = Time.now
        block.save
        hr = block.time >= 60 ? (block.time/60).to_s + ":" + (block.time%60).to_s : "00:" + block.time.to_s
        start_time = hr + ":00:00"
      else
        if (Time.now - block.start_time) > block.time * 60
          start_time = "00:00:00:00"
        else
          leaving_time = (block.time - (Time.now - block.start_time)/60).round
          hr = leaving_time >= 60 ? (leaving_time/60).to_s + ":" + (leaving_time%60).to_s : "00:" + leaving_time.to_s
          start_time = hr + ":00:00"
        end
      end
    end
    render :text => start_time
  end
    

end
