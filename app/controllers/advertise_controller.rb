class AdvertiseController < ApplicationController

  def index  
    @exam_category = params[:category_id]
    @examination=Examination.find_by_sql("select * from examinations ex  where ex.category_id=#{@exam_category} and ex.exam_free_end_at>'#{Time.now}' order by exam_free_end_at asc limit 1")
    if !@examination[0].nil?
    @free_num=ExamUser.find_by_sql("select * from exam_users where is_free=1 and examination_id=#{@examination[0].id}").size
    end
  end
  
  def join
    @examination = Examination.find(params[:examination_id])
    exam_user = ExamUser.create(:user_id => cookies[:user_id].to_i,:examination_id => params[:examination_id].to_i,
      :password => User::DEFAULT_PASSWORD, :is_user_affiremed => ExamUser::IS_USER_AFFIREMED[:YES],
      :is_free => ExamUser::IS_FREE[:YES])
    exam_user.set_paper(@examination)
    render :partial=>'notice'
  end

  def kaoshi
    redirect_to request.referer
  end
  
  def page

  end

  def login

    if User.find_by_email(params[:user][:email]).nil?&&params[:user][:email]!=nil?&&/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/.match(params[:user][:email])
      @user=User.new(:password=>params[:user][:email],:name=>params[:user][:name],:email=>params[:user][:email],:school=>params[:user][:school])
      @user.encrypt_password
      @user.set_role(Role.find(1))
      @user.status = 1
      if @user.save
        cookies[:user_id]=@user.id
        cookies[:user_name]=@user.name
        flash[:notice]="您现在可以使用赶考网了。当前帐号的密码已经发送到您的注册邮箱中，您可以随时使用该帐号和密码登录赶考网，请注意查收。"
        redirect_to request.referer
      else
        flash[:error]="SORRY,用户信息保存失败。"
        redirect_to request.referer
      end
    else
      flash[:error]="出错啦！注册邮箱已存在或者格式错误"
      redirect_to request.referer
    end
  end


end

