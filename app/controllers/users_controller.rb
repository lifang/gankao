#encoding: utf-8
class UsersController < ApplicationController
  before_filter :access?, :only => [:show, :update, :update_info]
  layout "login", :only => ["new", "active", "re_active", "active_success", "active_false"]

  def update #更新密码
    @user =User.find(params[:id])
    if @user.has_password?(params[:user][:old_password])
      @user.update_attributes(:password=>params[:user][:password])
      @user.encrypt_password
      @user.save
      flash[:notice] = "密码修改成功"
      redirect_to "/users/#{params[:id]}/edit"
    else
      flash[:error] = "您输入的密码不正确"
      render "edit"
    end
  end

  def update_info #更新用户信息
    @user_info = User.find(params[:id])
    @user_info.update_attributes(params[:user_info])
    flash[:notice]="用户信息修改成功"
    redirect_to "/user/homes/#{Category::TYPE_IDS[:english_fourth_level]}"
  end
  
  def new #新建用户页面
    session[:register_proof_code] = proof_code(4)
    @user = User.new
  end

  def create  #新建用户
    if User.find_by_email(params[:user][:email])
      flash[:emailused] = "此邮箱已被使用，请使用其他邮箱。"
      redirect_to "/users/new"
    else
      @user = User.new(params[:user])
      @user.username = params[:user][:name]
      @user.status = User::STATUS[:LOCK]
      @user.active_code = proof_code(6)
      @user.set_role(Role.find(Role::TYPES[:STUDENT]))
      @user.encrypt_password
      if @user.save!
        UserMailer.welcome_email(@user).deliver
        redirect_to "/users/#{@user.id}/active"
      else
        redirect_to "/users/new"
      end
    end
  end

  def re_active  #用户确认
    @flag = false
    unless params[:user_id].blank?
      @user = User.first(:conditions => ["id = ?", params[:user_id].to_i])
      if @user.status == true
        render :partial => "/users/re_active"
      else
        @flag = true
        UserMailer.welcome_email(@user).deliver
        render :partial => "/users/re_active"
      end if @user
    end
  end

  def active
    @user = User.find(params[:id].to_i)
  end

  def user_active  #确认成功
    if !params[:id].blank? and !params[:active_code].blank?
      @user = User.first(:conditions => ["id = ? and active_code = ?", params[:id].to_i, params[:active_code]])
      if @user
        @user.active_code = ""
        @user.status = true
        @user.save!

        cookies[:user_id] = @user.id
        cookies[:user_name] = @user.name
        redirect_to "/users/active_success"
      else
        redirect_to "/users/active_false"
      end
    end
  end

  def show  
    @user=User.find(params[:id])
    @examinations = Examination.paginate_by_sql("select eu.is_submited, eu.total_score u_total_score,
        p.total_question_num, ex.*, ex.id ex_id, eu.id eu_id, eu.started_at, eu.is_free
        from exam_users eu inner join examinations ex on ex.id = eu.examination_id
        inner join papers p on p.id=eu.paper_id where eu.user_id = #{@user.id}
        and ex.is_published = 1 order by start_at_time desc",
      :per_page =>10, :page => params[:page])
  end


  def get_proof_code   
    session[:proof_code] = proof_code(4)
    render :inline => session[:proof_code]
  end

  def edit
    @user= User.find(params[:id])
    render :layout => "member"
  end

  def edit_password
    @user= User.find(params[:id])
    render :layout => "member"
  end

  def get_register_code
    session[:register_proof_code] = proof_code(4)
    render :inline => session[:register_proof_code]
  end

  def roles_manage
    @roles = Role.all
  end

  def load_set_right
    @rights = Constant::RIGHTS
    @role = Role.find(params[:role_id])
    render :partial => "/users/set_right",:object =>@role
  end

  def set_right
    @role_id=params[:right][:role_id].to_i
    @rights_num=params[:right][:right_num].to_i
    @right_sum=0
    (0..@rights_num).each do |id|
      puts params["check_box#{id}"]
      if params["check_box#{id}"]!=nil && params["check_box#{id}"] != ""
        @right_sum += params["check_box#{id}"].to_i
      end
    end
    @model_role = ModelRole.find_by_role_id(@role_id)
    if @model_role == nil
      ModelRole.create(:role_id=>@role_id,:right_sum=>@right_sum)
    else
      @model_role.update_attributes(:right_sum=>@right_sum)
    end
    redirect_to request.referer
  end

  def goto_vip
    render :layout => "member"
  end

end

