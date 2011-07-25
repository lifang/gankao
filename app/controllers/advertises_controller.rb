class AdvertisesController < ApplicationController

  def show
    @exam_category = params[:id]
    @examination = Examination.where("category_id = #{@exam_category} and exam_free_end_at > '#{Time.now}'").
      order("exam_free_end_at ASC").first
    unless @examination.nil?
      @free_num = ExamUser.count("id",
        :conditions => "is_free = #{ExamUser::IS_FREE[:YES]} and examination_id = #{@examination.id}")
      @all_count = @examination.exam_users.count
      @can_join = (Constant::FREE_NUM - @free_num > 0 and
          !@examination.is_user_in(cookies[:user_id]) and @examination.get_free_end_at >= Time.now) ? true : false
    else
      flash[:error]="新的模拟考试还未开始。"
    end
  end
  
  def join
    @examination = Examination.find(params[:examination_id])
    @free_num = ExamUser.count("id",:conditions => "is_free = #{ExamUser::IS_FREE[:YES]} and examination_id = #{@examination.id}")
    if @examination.get_free_end_at >= Time.now and @free_num == Constant::FREE_NUM
      exam_user = ExamUser.create(:user_id => cookies[:user_id].to_i,:examination_id => params[:examination_id].to_i,
        :password => User::DEFAULT_PASSWORD, :is_user_affiremed => ExamUser::IS_USER_AFFIREMED[:YES],
        :is_free => ExamUser::IS_FREE[:YES])
      exam_user.set_paper(@examination)
    else
      flash[:warn] = "当前免费领取已经结束。"
    end
    render :partial=>'notice'
  end

  def kaoshi
    redirect_to request.referer
  end

  def login
    if User.find_by_email(params[:user][:email]).nil?
      if params[:user][:email] != nil? and /^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/.match(params[:user][:email])
        @user=User.auto_add_user(params[:user][:name],params[:user][:user_name],params[:user][:email],nil)
        cookies[:user_id]=@user.id
        cookies[:user_name]=@user.name
        flash[:notice]="您现在可以使用赶考网了。默认密码: 123456 ，您可以使用该邮箱和密码登录赶考网。"
      else
        flash[:error]="注册邮箱输入错误，请输入有效的邮箱。"
      end
    else
      flash[:error]="该邮箱已经被注册，请登录试试。"
    end
    redirect_to request.referer
  end


end

