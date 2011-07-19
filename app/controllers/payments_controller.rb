class PaymentsController < ApplicationController
  def payoff
    @examination=Examination.find(params[:id])
  end
  def packed_payoff
    @examination=Examination.all
  end
  def agency_recharge
    @examination=Examination.all
  end
  def search_account
    @examination=Examination.all
    @user=User.find_by_email(params[:agency_account])
    if @user
      render "agency_recharge"
    else
      flash[:error]="用户不存在，请核实"
      redirect_to "/payments/agency_recharge"
    end
  end
end
