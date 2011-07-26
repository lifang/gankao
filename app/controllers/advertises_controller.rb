class AdvertisesController < ApplicationController

  def index  
    @exam_category = params[:category_id]
    @examination=Examination.where("category_id = #{@exam_category} and exam_free_end_at>'#{Time.now}'").order("exam_free_end_at ASC").first
    if !@examination.nil?
    @free_num=ExamUser.count("id",:conditions=>" is_free=1 and examination_id=#{@examination.id}")
    else
      if @exam_category==2
      flash[:error]="当前没有四级模拟考试"
      else
      flash[:error]="当前没有六级模拟考试"
      end
     redirect_to "/pages"
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

    if User.find_by_email(params[:user][:email]).nil?
      if params[:user][:email]!=nil?&&/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/.match(params[:user][:email])
      @user=User.auto_add_user(params[:user][:name],params[:user][:user_name],params[:user][:email],nil)
      
        cookies[:user_id]=@user.id
        cookies[:user_name]=@user.name
        flash[:notice]="您现在可以使用赶考网了。默认密码: 123456 ，您可以使用该邮箱和密码登录赶考网。"
        redirect_to request.referer
      else
        flash[:error]="注册邮箱输入错误，请输入有效的邮箱"
        redirect_to request.referer
      end
    else
      flash[:error]="该邮箱已经被注册，请登录试试。默认密码 ：123456 "
      redirect_to request.referer
    end
  end


end

