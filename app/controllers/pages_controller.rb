class PagesController < ApplicationController
  def index
    
  end

  def new
    @examinations=Examination.where("type=?",Examination::TYPES[:SIMULATION])
  end
  def sina_index
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    oauth.authorize_from_request(session[:rtoken],session[:rsecret], params[:oauth_verifier])
    session[:rtoken], session[:rsecret] = nil, nil
    session[:atoken], session[:asecret] = oauth.access_token.token, oauth.access_token.secret
    user_info = Weibo::Base.new(oauth).verify_credentials
    @user=User.where("code_id=#{user_info[:id]} and code_type='sina'").first
    if @user.nil?
      @user=User.create(:code_id=>user_info[:id],:code_type=>'sina',:name=>user_info[:name],:username=>user_info[:name])
    end
    cookies[:user_name] = user_info[:name]
    cookies[:user_id]=@user.id
    render :inline => "<script>window.opener.refresh();window.close();</script>"

  end

  
  def renren_index
    user_info = return_user(return_session_key(return_access_token(params[:code])))[0]
    @user=User.where("code_id=#{user_info["uid"].to_s} and code_type='renren'").first
    if @user.nil?
      @user=User.create(:code_id=>user_info["uid"],:code_type=>'renren',:name=>user_info["name"],:username=>user_info["name"])
    end
    cookies[:user_name] = @user.name
    cookies[:user_id]=@user.id
    render :inline => "<script>window.opener.refresh();window.close();</script>"

  end

end