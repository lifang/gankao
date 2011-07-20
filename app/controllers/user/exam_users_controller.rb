class User::ExamUsersController < ApplicationController
  require 'rexml/document'
  include REXML
  def show
    @exam=ExamUser.find_by_user_id_and_examination_id(params[:user_id],params[:id])
    begin
    @doc=ExamRater.open_file("/result/#{@exam.id}.xml")
    @xml=ExamUser.show_result(@exam.paper_id, @doc)
    rescue
      flash[:error] = "当前考试试卷不能正常打开，请检查试卷是否正常。"
      redirect_to request.referer
    end
  end

  def edit_score
    ExamUser.edit_scores(params[:user_id],params[:id],params[:score])
    render :inline => ""
  end

  def my_results   #考生成绩
    @exam_user=ExamUser.find_by_user_id(cookies[:user_id])
    sql = ExamUser.generate_result_sql
    sql += " and us.id=#{cookies[:user_id]} "
    @results=Examination.paginate_by_sql(sql,:per_page =>10, :page => params[:page])
  end


  def search
    session[:start_at] = nil
    session[:end_at] = nil
    session[:title] = nil
    session[:start_at] = params[:start_at] if !params[:start_at].nil? and params[:start_at] != ""
    session[:end_at] = params[:end_at] if !params[:end_at].nil? and params[:end_at] != ""
    session[:title] = params[:title] if !params[:title].nil? and params[:title] != ""
    redirect_to "/user/exam_users/search_list"
  end

  def search_list #成绩查询
    @exam_user=ExamUser.find_by_user_id(cookies[:user_id])
    sql = ExamUser.generate_result_sql
    sql += " and us.id=#{cookies[:user_id]}"
    sql += " and e.start_at_time >= '#{session[:start_at]}'" unless session[:start_at].nil?
    sql += " and e.start_at_time <= '#{session[:end_at]}'" unless session[:end_at].nil?
    sql += " and e.title like '%#{session[:title]}%'" unless session[:title].nil?
    @results = Examination.paginate_by_sql(sql, :pre_page => 10, :page => params[:page])
    render "my_results"
  end
  
  def exam_session  #登陆查看成绩
    @user = User.find_by_email(params[:session][:email])
    if @user.nil?
      flash[:error] = "邮箱不存在"
      redirect_to '/user/exam_users/session_new'
    else
      unless  @user.has_password?(params[:session][:password])
        flash[:error] = "密码错误"
        redirect_to '/user/exam_users/session_new'
      else
        cookies[:exam_user_id]=@user.id
        redirect_to "/user/exam_users/"
      end
    end
  end
  
  def index
    @user=User.find(cookies[:exam_user_id])
    @exam_users=ExamUser.find_by_sql("select * from exam_users e where e.user_id=#{@user.id}")
  end
  
  #考生确认
  def exam_user_affiremed   
    if !params[:id].blank? and !params[:affiremed].blank?
      @exam_user = ExamUser.first(:conditions => ["id = ? and is_user_affiremed = ?", params[:id].to_i, params[:affiremed]])
      @user=User.find(params[:user_id])
      if @exam_user
        @examination=Examination.find(@exam_user.examination_id)
        flash[:title]=",恭喜您参加 #{@examination.title} 的考试,请确认！"
        render "/user/exam_users/affiremed_success"
      else
        redirect_to "/user/exam_users/affiremed_false"
      end
    end
  end

  def edit_name #考生确认时修改考生姓名
    @examination=Examination.find(params[:examination])
    @exam_user=ExamUser.find(params[:exam_user])
    @user=User.find(params[:id])
    @exam_user.user_affiremed
    @user.name=params[:name]
    flash[:success]="恭喜您成功确认"
    @exam_user.save
    @user.save
    render "/user/exam_users/affiremed_success"
  end
end
