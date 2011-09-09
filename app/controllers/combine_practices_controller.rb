#encoding: utf-8
class CombinePracticesController < ApplicationController
  before_filter :access?
  layout "gankao"

  def index
    @all_practies = Examination.return_exam_count(Examination::TYPES[:PRACTICE])
    @practies_count = ExamUser.return_join_exam_count(Examination::TYPES[:PRACTICE], cookies[:user_id].to_i)
    @practies_precent = @all_practies != 0 ? ((@practies_count.to_f/@all_practies)*100).round : 0
  end

  def start
    can_practies = true
    practies_count = ExamUser.return_join_exam_count(Examination::TYPES[:PRACTICE], cookies[:user_id].to_i)
    can_practies = false unless is_vip? and practies_count < Constant::PRACTICES_COUNT
    if can_practies
      all_practies = Examination.return_exam_count(Examination::TYPES[:PRACTICE])
      if all_practies <= practies_count
        flash[:notice] = "您的综合训练已经全部做完。"
        redirect_to "/combine_practices"
      else
        examination = Examination.rand_examnation(Examination::TYPES[:PRACTICE], cookies[:user_id].to_i)
        if examination and examination[0]
          redirect_to "/user/combine_practices/#{examination[0].id}/start"
        else
          flash[:notice] = "您的综合训练已经全部做完。"
          redirect_to "/combine_practices"
        end
      end
    else
      flash[:error] = "您只能参与#{Constant::PRACTICES_COUNT}次综合训练，如果您想参与更多，请升级为VIP"
      redirect_to "/combine_practices"
    end
  end


end
