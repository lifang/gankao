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
    @feedbacks=Feedback.find_by_sql("select * from feedbacks where user_id=#{cookies[:user_id]}")
  end
  def feedback
     @feedback=Feedback.new(:description=>params[:feedback][:description],:user_id=>"#{cookies[:user_id]}")
     if @feedback.save
     redirect_to "/exam_lists/incorrect_list"
     end
    @incorrect_list=Collection.find_by_user_id(cookies[:user_id]).open_xml.root
  end

  def show_problem
    doc=Collection.find_by_user_id(cookies[:user_id]).open_xml
    hash1={}
    doc.elements["/collection/problems"].each_element do |problem|
      problem.elements["questions"].each_element do |question|
        hash1["#{question.attributes["id"]}"]=[question.elements["answer_agains"].elements.size,problem.attributes["id"]]
      end
    end
    n=[]
    hash1.each do |key,value|
      n<<value[0]
    end
    n.sort
    hash1.each do |key,value|
     @xml=doc.elements["/collection/problems/problem[@id='#{value[1]}']"] if n[0]==value[0]
    end
    puts @xml
    render :partial=>"/exam_lists/question_info",:object=>@xml
  end

end
