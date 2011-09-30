#encoding: utf-8
class User::CombinePracticesController < ApplicationController
  layout "paper", :only => [:save_result]
  before_filter :access?
  include REXML
  require 'rexml/document'

  def show
    arr = ExamUser.can_answer(cookies[:user_id].to_i, params[:id].to_i)
    if arr[0] == "" and arr[1].any?
      @examination = arr[1][0]
      @exam_user = ExamUser.find_by_examination_id_and_user_id(@examination.id, cookies[:user_id].to_i)
      @exam_user = ExamUser.create(:user_id => cookies[:user_id],:examination_id => @examination.id,
        :password => User::DEFAULT_PASSWORD, :is_user_affiremed => ExamUser::IS_USER_AFFIREMED[:YES]) if @exam_user.nil?
      if @exam_user and @exam_user.paper_id
        @step=@exam_user.get_step(@exam_user.open_xml)
        @practice_type=@step[0].to_i+1    #因为js中，综合训练类型1-5，分别对应2-6.而step为1..5
        @paper_url = "#{Constant::PAPER_CLIENT_PATH}/#{@exam_user.paper_id}.js"
        xml_url="#{Constant::BACK_PUBLIC_PATH}/papers/#{@exam_user.paper_id}.xml"
        xml=Document.new(File.open(xml_url)).root
        @answer_array=xml.get_elements("/paper/blocks/block[#{@step[0].to_i}]/problems//questions//answer").map{|n|n=n.text}.join("|-|-|").gsub("\"","")
        render :layout => "practice_layout"
      else
        flash[:warn] = "试卷加载错误。"
        redirect_to "/user/examinations"
      end
    else
      flash[:warn] = arr[0]
      redirect_to request.referer
    end
  end

  def start
    @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id].to_i, cookies[:user_id].to_i)
    if @exam_user.nil?
      @exam_user = ExamUser.create(:user_id => cookies[:user_id],:examination_id => params[:id].to_i,
        :password => User::DEFAULT_PASSWORD, :is_user_affiremed => ExamUser::IS_USER_AFFIREMED[:YES])
      @exam_user.set_paper(@examination) if @exam_user.paper_id.nil?
      @exam_user.create_practice_result
    end
    @step=@exam_user.get_step(@exam_user.open_xml)
    if @step.to_i<=5
      redirect_to "#{Constant::SERVER_PATH}/user/combine_practices/#{params[:id]}"
    else
      @exam_user.submited!       # @step=6 完成该综合训练
      flash[:notice] = "你顺利完成了一份综合训练题，再接再厉。"
      redirect_to "/combine_practices/#{Examination::TYPES[:PRACTICE]}"
    end
  end

  def check_step
    @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id].to_i, cookies[:user_id].to_i)
    @step=@exam_user.get_step(@exam_user.open_xml)
    @practice_type=@step.to_i+1
    if @step.to_i<5
      flash[:notice] = "恭喜你进入下一关。"
      @exam_user.next_step(@exam_user.open_xml,@exam_user.answer_sheet_url)
      redirect_to "#{Constant::SERVER_PATH}/user/combine_practices/#{params[:id]}"
    else
      @exam_user.submited! # @step=6 完成该综合训练
      flash[:notice] = "恭喜你顺利完成了一份综合训练题。"
      redirect_to "/combine_practices/#{Examination::TYPES[:PRACTICE]}"
      return 0
    end
  end
end

def save_result
  
end

