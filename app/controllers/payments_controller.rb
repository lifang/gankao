class PaymentsController < ApplicationController
  before_filter :access?
  
  def payoff
    @examination=Examination.find(params[:id])
  end
  
  def packed_payoff
    @examination=Examination.find_all_by_category_id(params[:id])
  end

  def agency_recharge
    @categories=Category.all
    @examination_info={}
    @user_info={}
    @categories.each do |category|
      @examination_info["#{category.id}"]=[category.examinations,category.id]
    end
  end

  def search_account
    @user=User.find_by_email(params["agency_account#{params[:id]}"])
    if @user
      render :partial=>"/payments/user_info",:object=>params[:id]
    else
      flash[:user_info]="用户不存在，请重新输入查询条件。"
      redirect_to request.referer
    end
  end
end
