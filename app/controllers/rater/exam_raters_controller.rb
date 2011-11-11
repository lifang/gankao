#encoding: utf-8
class Rater::ExamRatersController < ApplicationController
  layout "rater"
  def rater_session #阅卷老师登陆页面
    @rater=ExamRater.find(:first,:conditions =>["id = #{params[:id].to_i} and examination_id = #{params[:examination].to_i}"])
    if @rater.nil?
      render :inline=>"您访问的页面不存在。"
    else
      @examination=Examination.find(params[:examination])
      render "/rater/exam_raters/session"
    end    
  end
  
  def rater_login  #阅卷老师登陆
    @rater=ExamRater.find(params[:id])
    @examination=Examination.find(params[:examination_id])
    if @rater.author_code==params[:author_code]
      cookies[:rater_id]={:value =>@rater.id, :path => "/", :secure  => false}
      flash[:success]="登陆成功"
      redirect_to  "/rater/exam_raters/#{params[:examination_id]}/reader_papers?rater_id=#{@rater.id}"
    else
      flash[:error]="阅卷码不正确，请核对！"
      render "/rater/exam_raters/session"
    end
  end
  
  def reader_papers  #答卷批阅状态显示
    auth_rater=ExamRater.find(:first,:conditions =>["id = #{cookies[:rater_id].to_i} and examination_id = #{params[:id].to_i}"])
    if auth_rater.nil?
      redirect_to "/rater/exam_raters/#{params[:rater_id]}/rater_session?examination=#{params[:id]}"
    else
      @examination=Examination.find(params[:id].to_i)
      @user=User.find(@examination.creater_id)
      @exam_paper_total =ExamUser.get_paper(params[:id].to_i)
      @exam_score_total =0
      @exam_paper_marked =0
      @marked_now=0
      @rater_id=cookies[:rater_id]
      @exam_paper_total.each do |e|
        @marked_now +=1 if e.exam_rater_id==cookies[:rater_id].to_i and e.is_marked!=1
        @exam_score_total +=1 unless e.relation_id
        @exam_paper_marked +=1 if e.is_marked==1
      end unless @exam_paper_total.blank?
    end
  end
  
  def check_paper  #选择要批阅的答卷
    @exam_user=RaterUserRelation.find_by_sql("select * from rater_user_relations
      where exam_rater_id=#{cookies[:rater_id].to_i} and is_marked=0")
    if @exam_user.blank?||@exam_user==[]
      examination=params[:examination_id].to_i
      if examination==Constant::EXAMINATION.to_i
        @exam_user= ExamUser.find_by_sql("select eu.id from exam_users eu left join rater_user_relations r
        on r.exam_user_id = eu.id where eu.answer_sheet_url is not null and
        eu.is_submited=1 and eu.examination_id = #{examination} and r.exam_user_id is null order by rand() limit 1")
      else
        @exam_user= ExamUser.find_by_sql("select eu.id from exam_users eu left join rater_user_relations r
        on r.exam_user_id = eu.id inner join orders o on o.user_id = eu.user_id where eu.answer_sheet_url is not null and
        eu.is_submited=1 and eu.examination_id = #{examination} and r.exam_user_id is null order by rand() limit 1")
      end    
      id=@exam_user[0].id
    else
      id=@exam_user[0].exam_user_id
    end
    unless @exam_user.blank?
      redirect_to "/rater/exam_raters/#{id}/answer_paper?rater_id=#{cookies[:rater_id]}"
    else
      flash[:notice] = "当场考试试卷已经全部阅完。"
      redirect_to request.referer
    end
  end
  
  def answer_paper #批阅答卷
    @exam_user=ExamUser.find(params[:id])
    if @exam_user.nil?
      render :inline=>"您访问的页面不存在。"
    else
      doc=ExamRater.open_file(Constant::PUBLIC_PATH + @exam_user.answer_sheet_url)
      xml=ExamRater.open_file(Constant::BACK_PUBLIC_PATH + "/papers/#{doc.elements[1].attributes["id"]}.xml")
      @xml=ExamUser.answer_questions(xml,doc)
      @reading= RaterUserRelation.find(:first, :conditions => ["exam_rater_id=#{cookies[:rater_id]} and is_marked=0"])
      if @xml.attributes["ids"].to_s == "-1"
        flash[:notice] = "感谢您的参与，当前试卷没有需要批改的试卷。"
      else
        if @reading.nil?
          @reading=RaterUserRelation.create(:exam_rater_id => cookies[:rater_id],
            :exam_user_id => @exam_user.id, :started_at =>Time.now,:is_marked=>0)
        end
      end
    end
  
  end

  def over_answer #批阅完成，给答卷添加成绩
    @exam_relation=RaterUserRelation.find(params[:id])
    @exam_relation.toggle!(:is_marked)
    @exam_relation.update_attributes(:rate_time=>((Time.now-@exam_relation.started_at)/60+1).to_i)
    @exam_user=ExamUser.find(@exam_relation.exam_user_id)
    url="#{Rails.root}/public/#{@exam_user.answer_sheet_url}"
    doc=ExamRater.open_file(url)
    collection = Collection.find_or_create_by_user_id(@exam_user.user_id)
    collection.set_collection_url
    collection_xml = collection.open_xml
    xml=ExamRater.open_file(Constant::BACK_PUBLIC_PATH + "/papers/#{doc.elements[1].attributes["id"]}.xml")
    score=0.0
    only_xml=ExamUser.answer_questions(xml,doc)
    only_xml.elements["blocks"].each_element do  |block|
      block_score = 0.0
      original_score = 0.0
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          single_score = params["single_value_#{question.attributes["id"]}"].to_f
          reason = params["reason_for_#{question.attributes["id"]}"]
          result_question = doc.elements["/exam/paper/questions/question[@id=#{question.attributes["id"]}]"]
          answer = (result_question.elements["answer"].nil? or result_question.elements["answer"].text.nil?) ? ""
          : result_question.elements["answer"].text
          if question.attributes["score"].to_f == single_score
            problem.delete_element(question.xpath)
          else
            collection_xml = @exam_user.add_collection(collection, xml, collection_xml, problem,
              question, answer) unless problem.elements["questions"].elements[1].nil?
          end
          original_score += result_question.attributes["score"].to_f
          result_question.attributes["score"] = single_score
          score += single_score
          block_score += single_score
          question.add_attribute("user_answer","#{answer}")
          result_question.add_attribute("score_reason","#{reason}")
        end unless problem.elements["questions"].nil?
      end
      unless doc.elements["/exam/paper/blocks"].nil?
        answer_block = doc.elements["/exam/paper/blocks/block[@id=#{block.attributes["id"]}]"]
        block_score = answer_block.attributes["score"].to_f - original_score + block_score
        answer_block.attributes["score"] = block_score
      end
    end
    collection.generate_collection_url(collection_xml.to_s)
    doc.elements["paper"].elements["rate_score"].text = score
    @xml=ExamRater.rater(doc,@exam_user.id,score)
    self.write_xml(url, doc)
    redirect_to "/rater/exam_raters/#{ @exam_user.examination_id}/reader_papers?rater_id=#{@exam_relation.exam_rater_id}"
  end

  def destroy #退出
    cookies.delete(:rater_id)
    cookies.delete(:examination_id)
    render :inline=>"<script>window.close();</script>"
  end

  def show
    @exam_rater=ExamRater.find(params[:id])
  end
  
  def edit_value #编辑姓名
    @exam_rater=ExamRater.find(params[:id])
    @exam_rater.update_attributes(:name=>params[:value])
    render :inline=>"姓&nbsp;&nbsp;&nbsp;&nbsp;名:#{ @exam_rater.name}"
  end
  
  def index #参加的阅卷列表
    if cookies[:rater_id].nil?
      render :inline=>"您访问的页面不存在。"
    else
      @exam_rater=ExamRater.find(cookies[:rater_id])
      @exam_list=ExamRater.find_all_by_email(@exam_rater.email)
    end
   
  end
end
