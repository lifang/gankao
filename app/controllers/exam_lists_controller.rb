class ExamListsController < ApplicationController
  def simulate_list
    @examination_lists=Examination.all
#      where("types=?",Examination::TYPES[:SIMULATION])
  end
end
