class ExamListsController < ApplicationController
  def simulate_list
    @examination_lists=Examination.where("types=?",Examination::TYPES[:SIMULATION])
  end
  def old_exam_list
    @old_lists=Examination.where("types=?",Examination::TYPES[:OLD_EXAM])
  end
  def incorrect_list
    collection_id=Collection.find_by_user_id(cookies[:user_id]).id
    @incorrect_list=ExamRater.open_file("#{Rails.root}/public/collections/#{collection_id}.xml")
  end
end
