class User::CombinePracticesController < ApplicationController
  layout "paper", :only => [:save_result]
  before_filter :access?
  include REXML
  require 'rexml/document'

  def show
    @practice_type=params[:practice_type]
    Examination::TYPE_NAMES.each_value do |array|
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
        if params[:show_answer]
          xml_url="#{Constant::BACK_PUBLIC_PATH}/papers/#{@exam_user.paper_id}.xml"
          xml=Document.new(File.open(xml_url)).root
          @answer_array=xml.to_s.split("<answer>").each.map{|answer| answer=answer.split("</answer>")[0]}[1..-1]
        end
        render :layout => "practice_layout"
        #       render :layout =>'application'
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
    @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id].to_i, cookies[:user_id].to_i)
    if params[:submit]==nil
      arr = ExamUser.can_answer(cookies[:user_id], params[:id].to_i)
      flash[:notice] = "标准答案已给出，请检查。"
      if arr[0] == "" and arr[1].any?
        render :inline => "<iframe src='#{Constant::SERVER_PATH}/user/combine_practices/#{params[:id]}/?practice_type=#{params[:practice_type]}&show_answer=1'
            frameborder='0' style='width: 1270px; height: 760px;'></iframe>"
      end
    else
      @exam_user.submited!
      flash[:notice] = "你顺利完成了一份综合训练题，再接再厉。"
      redirect_to "/combine_practices"
    end
  end


end
