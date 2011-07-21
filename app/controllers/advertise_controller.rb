class AdvertiseController < ApplicationController

  def index
    @examination=Examination.find_by_sql("select * from examinations order by exam_free_end_at desc limit 1")
  end

  def lingqu
    ExamUser.create(:user_id=>cookies[:user_id],:examination_id=>params[:lingqu][:examination_id],:paper_id=>params[:lingqu][:paper_id])
    flash[:notice]="考试名额领取成功"
    redirect_to request.referer
  end

  def kaoshi
    redirect_to request.referer
  end

end
