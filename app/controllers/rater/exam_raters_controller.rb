class Rater::ExamRatersController < ApplicationController
  layout "rater"

  def rater_session #阅卷老师登陆页面
    @rater=ExamRater.find(params[:id])
    @examination=Examination.find(params[:examination])
    render "/rater/exam_raters/session"
  end
  
  def rater_login  #阅卷老师登陆
    @rater=ExamRater.find(params[:id])
    @examination=Examination.find(params[:examination_id])
    if @rater.author_code==params[:author_code]
      cookies[:rater_id]=@rater.id
      flash[:success]="登陆成功"
      redirect_to  "/rater/exam_raters/#{@examination.id}/reader_papers"
    else
      flash[:error]="阅卷码不正确，请核对！"
      render "/rater/exam_raters/session"
    end
  end
  
  def reader_papers  #答卷批阅状态显示
    @examination=Examination.find(params[:id])
    @exam_paper_total =ExamUser.get_paper(params[:id])
    @user=User.find(@examination.creater_id)
    @exam_score_total = 0
    @exam_paper_marked = 0
    @exam_paper_total.each do |e|
      @exam_score_total +=1 unless e.relation_id
      @exam_paper_marked +=1 if e.is_marked==1
    end unless @exam_paper_total.blank?
  end
  
  def check_paper  #选择要批阅的答卷
    @exam_user= ExamUser.find_by_sql("select eu.id from exam_users eu
      left join rater_user_relations r on r.exam_user_id = eu.id
      where eu.answer_sheet_url is not null and eu.examination_id = #{params[:examination_id].to_i}
      and r.exam_user_id is null order by rand() limit 1")
    unless @exam_user.blank?
      redirect_to "/rater/exam_raters/#{@exam_user[0].id}/answer_paper"
    else
      flash[:notice] = "当场考试试卷已经全部阅完。"
      redirect_to request.referer
    end
  end
  
  def answer_paper #批阅答卷
    @exam_user=ExamUser.find(params[:id])
    doc=ExamRater.open_file(Constant::PUBLIC_PATH+@exam_user.answer_sheet_url)
    xml=ExamRater.open_file(Constant::BACK_PUBLIC_PATH+"/papers/#{doc.elements[1].attributes["id"]}.xml")
    @xml=ExamUser.answer_questions(xml,doc)
    if @xml.attributes["ids"] == "-1"
      flash[:notice] = "感谢您的参与，当前试卷没有需要批改的试卷。"
      redirect_to request.referer
    else
      RaterUserRelation.create(:exam_rater_id => cookies[:rater_id],
        :exam_user_id => @exam_user.id, :started_at => Time.now)
    end
  end

  def over_answer #批阅完成，给答卷添加成绩
    @exam_relation=RaterUserRelation.find_by_exam_user_id(params[:id])
    @exam_relation.toggle!(:is_marked)
    @exam_relation.update_attributes(:rate_time=>((Time.now-@exam_relation.started_at)/60+1).to_i)
    @exam_user=ExamUser.find(params[:id])
    url="#{Rails.root}/public/result/#{params[:id]}.xml"
    doc=ExamRater.open_file(url)
    xml=ExamRater.open_file(Constant::BACK_PUBLIC_PATH+"/papers/#{doc.elements[1].attributes["id"]}.xml")
    score=0
    only_xml=ExamUser.answer_questions(xml,doc)
    doc.elements[1].elements[1].each_element do |element|
      single_score=params["single_value_#{element.attributes["id"]}"]
      only_xml.elements["blocks"].each_element do  |block|
        block.elements["problems"].each_element do |problem|
          num=0
          problem.elements["questions"].each_element do |question|
            if element.attributes["id"]==question.attributes["id"]
              question.add_element("answer_agains").add_element("answer_again").add_text(element.elements["answer"].text)
              if question.attributes["score"]!=single_score
                num=1 
              else
                problem.delete_element(question.xpath)
              end
            end
          end
          @exam_user.add_collection(problem.to_s,@exam_user,problem.attributes["id"].to_i) unless problem.elements["questions"].elements[1].nil? if num==1
        end
      end
      element.add_attribute("score","#{single_score}")
      score +=element.attributes["score"].to_i
    end
    doc.elements["paper"].elements["rate_score"].text=score
    @xml=ExamRater.rater(doc,params[:id],score)
    self.write_xml("#{Constant::PUBLIC_PATH}"+url, doc)
    redirect_to "/rater/exam_raters/#{ @exam_user.examination_id}/reader_papers"
  end

  def destroy #退出
    cookies.delete(:rater_id)
    cookies.delete(:examination_id)
    render :inline=>"<script>window.close();</script>"
  end

  def show
    @exam_rater=ExamRater.find(params[:id])
  end
  def edit_value #编辑考分
    @exam_rater=ExamRater.find(params[:id])
    @exam_rater.update_attributes(:name=>params[:value])
    render :inline=>"name"
    render :inline=>"姓&nbsp;&nbsp;&nbsp;&nbsp;名:#{ @exam_rater.name}"
  end
  
  def index #参加的阅卷列表
    @exam_rater=ExamRater.find(cookies[:rater_id])
    @exam_list=ExamRater.find_all_by_email(@exam_rater.email)
  end
end
