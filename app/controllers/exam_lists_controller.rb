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
    hash={}
    hash1={}
    doc.elements["/collection/problems"].each_element do |problem|
      hash["#{problem.attributes["id"]}"]=problem.attributes["incorrect_num"]
    end
    hash.each do |key,value|
      if hash1["#{value}"].nil?
        hash1["#{value}"]=key
      else
        hash1["#{value}"] += ","+key
      end
    end
    str=""
    hash1.keys.sort.each do |key|
      str +=hash1[key]+","
    end
    @num=str.chop.split(",")
    @str=(@num-[@num[0]]).join(",")
    @xml=doc.elements["/collection/problems/problem[@id='#{@num[0]}']"]
    render :partial=>"/exam_lists/question_info",:object=>@xml
  end

  def next_problem
    @num=params[:num].split(",")
    @str=(@num-[@num[0]]).join(",")
    doc=Collection.find_by_user_id(cookies[:user_id]).open_xml
    @xml=doc.elements["/collection/problems/problem[@id=#{@num[0]}]"]
    render :partial=>"/exam_lists/question_info",:object=>@xml
  end

  def compare_answer
    @str=params[:num]
    problem_id=params[:problem_id]
    ids=params[:question_ids].split(",")
    collection=Collection.find_by_user_id(cookies[:user_id])
    doc=collection.open_xml
    ids.each do |id|
      doc.elements["/collection/problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          if question.attributes["id"]==id
            if params["answer_#{id}"]==question.elements["answer"].text
              correct_percent=1.0/(question.elements["answer_agains"].elements.size+1)*100
              question.add_attribute("correct_percent","#{correct_percent.to_i}%")
            else
              question.elements["answer_agains"].add_element("answer_again").add_element("user_answer").add_text(params["answer_#{id}"])
              problem.attributes["incorrect_num"] =problem.attributes["incorrect_num"].to_i+1
            end
          end
        end
      end
    end
    self.write_xml("#{Constant::PUBLIC_PATH}#{collection.collection_url}", doc)
    doc=collection.open_xml
    @xml=doc.elements["/collection/problems/problem[@id='#{problem_id}']"]
    render :partial=>"/exam_lists/question_answer",:object=>@xml
  end

end
