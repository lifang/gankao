#encoding: utf-8
class PaymentsController < ApplicationController
  before_filter :access?
  #单场购买
  def payoff
    @examination=Examination.find(params[:id])
  end

  #打包购买
  def packed_payoff
    @examination=Examination.where("category_id=#{params[:id]}")
  end
   
  #代理充值
  def agency_recharge
    @categories=Category.all
    @examination_info={}
    @user_info={}
    @categories.each do |category|
      @examination_info["#{category.id}"]=[category.examinations,category.id]
    end
  end

  #账户查询
  def search_account
    @user=User.find_by_email(params["agency_account#{params[:id]}"])
    if @user
      render :partial=>"/payments/user_info"
    else
      render :inline=>"用户不存在，请重新输入查询条件。"
    end
  end
end
