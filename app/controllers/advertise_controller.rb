class AdvertiseController < ApplicationController

  def index  
    @exam_category = params[:category_id]
    @examination=Examination.find_by_sql("select * from examinations ex  where ex.category_id=#{@exam_category} and ex.exam_free_end_at>'#{Time.now}' order by exam_free_end_at asc limit 1")
    @free_num=ExamUser.find_by_sql("select * from exam_users where is_free=1 and examination_id=#{@examination[0].id}").size
  end
  
  def lingqu
    ExamUser.create(:user_id=>cookies[:user_id],:examination_id=>params[:lingqu][:examination_id],:paper_id=>params[:lingqu][:paper_id],:is_free=>1)
    flash[:notice]="考试名额领取成功"
    redirect_to request.referer
  end

  def kaoshi
    redirect_to request.referer
  end
  
  def page

  end

  def login

    if User.find_by_email(params[:user][:email]).nil?
      @user=User.new(:password=>params[:user][:email],:name=>params[:user][:name],:email=>params[:user][:email],:school=>params[:user][:school])
      @user.encrypt_password
      @user.set_role(Role.find(1))
      @user.status = 1
      if @user.save
        cookies[:user_id]=@user.id
        cookies[:user_name]=@user.name
        ExamUser.create(:user_id=>@user.id,:examination_id=>params[:user][:examination_id],:paper_id=>params[:user][:paper_id],:is_free=>1)
        flash[:notice]="您现在可以参加考试了。提示：您可以用您的注册邮箱登录赶考网，密码处也填注册邮箱。您可以随时修改。"
        redirect_to request.referer
      else
        flash[:error]="SORRY,用户信息保存失败。"
        redirect_to request.referer
      end
    else
      flash[:error]="SORRY,注册邮箱已存在"
      redirect_to request.referer
    end
  end

end

