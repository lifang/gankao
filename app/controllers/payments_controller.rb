class PaymentsController < ApplicationController
  def payoff
    @examination=Examination.find(params[:id])
  end
  
  def packed_payoff
    @examination=Examination.all
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
    @categories=Category.all
    @examination_info={}
    @categories.each do |category|
      @examination_info["#{category.id}"]=[category.examinations,category.id]
    end
    @user=User.find_by_email(params["agency_account#{params[:id]}"])
    if @user
      @user_info={}
      @user_info["#{params[:id]}"]=@user
      render "agency_recharge"
    else
      flash[:error]="用户不存在，请重新输入查询条件。"
      redirect_to "/payments/agency_recharge"
    end
  end
end
