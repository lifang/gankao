#encoding: utf-8
class CombinePracticesController < ApplicationController
  before_filter :access?
  def index
    @type_sums = Examination.find_by_sql("select count(types) sums,types from examinations group by types")
    @sum_hash={}
    @type_sums.each do |types_and_sums|
      @sum_hash[types_and_sums.types]=types_and_sums.sums
    end
    @join_sums=Examination.find_by_sql("select count(types) joins,types from examinations ex inner join exam_users eu on eu.examination_id=ex.id where eu.is_submited=1 group by ex.types")
    @join_hash={}
    @join_sums.each do |types_and_joins|
    @join_hash[types_and_joins.types]=types_and_joins.joins
    end
  end

  def start
    if ExamUser.find_by_sql("select count(ex.id) count from examinations ex inner join exam_users eu on eu.examination_id=ex.id where ex.types=2")[0].count<=50000000000   #测试需要修改次数，默认为5.
      user_examinations=Examination.find_by_sql("select ex.id,eu.is_submited from examinations ex left join exam_users eu on ex.id=eu.examination_id where ex.types=2 and eu.user_id=#{cookies[:user_id]}")
      already_join=[]
      got=0
      user_examinations.each do |examination|
        if examination.is_submited==0
          got=1
          redirect_to "/user/combine_practices/#{examination.id}/start",:target=>"_blank"
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
          this_id=(all_choose-already_join).shuffle[0]
          redirect_to "/user/combine_practices/#{this_id}/start",:target=>"_blank"
        end
      end
    else
      flash[:error]="您当前已经使用完了免费的五次综合训练机会，请充值VIP，将取消次数限制。"
      redirect_to "/combine_practices"
    end
  end


end
