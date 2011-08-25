class CombinePracticesController < ApplicationController
  
  def index
    
  end

  def start

    if ExamUser.find_by_sql("select count(ex.id) count from examinations ex inner join exam_users eu on eu.examination_id=ex.id where ex.types in (2,3,4,5,6)")[0].count<=50000000000   #测试需要修改次数，默认为5.
    user_examinations=Examination.find_by_sql("select ex.id,eu.is_submited from examinations ex left join exam_users eu on ex.id=eu.examination_id where ex.types=#{params[:id].to_i} and eu.user_id=#{cookies[:user_id]}")
    already_join=[]
    got=0
    user_examinations.each do |examination|
      if examination.is_submited==0
        got=1
        redirect_to "/user/combine_practices/#{examination.id}/start?practice_type=#{params[:id].to_i}",:target=>"_blank"
      end
      already_join<<examination.id
    end
    examinations=Examination.find_all_by_types(params[:id].to_i)
    all_choose=[]
    if got==0
      examinations.each do |examination|
        all_choose<<examination.id
      end
      if all_choose-already_join==[]
        flash[:error]="你选择的综合训练已经全部做完。"
        redirect_to "/combine_practices"
      else
        this_id=(all_choose-already_join).sample
        redirect_to "/user/combine_practices/#{this_id}/start?practice_type=#{params[:id].to_i}",:target=>"_blank"
      end
    end
    else
      flash[:error]="您当前已经使用完了免费的五次综合训练机会，请充值VIP，将取消次数限制。"
      redirect_to "/combine_practices"
    end
  end

end
