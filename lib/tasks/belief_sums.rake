#encoding:utf-8
require 'rexml/document'
require 'rake'
include REXML
namespace :belief do
  desc "rate paper"
  task(:sums => :environment) do
    @examinations=Examination.find_by_sql("select count(types) sums,types from examinations group by types")
    users=User.find_by_sql("select u.belief,u.id from users u inner join orders o where u.id=o.user_id ")
    hash={}
    sums=0
    @examinations.each do |examination|
      if examination.types.to_i==1||examination.types.to_i==0
        hash["#{examination.types}"]=examination.sums
      else
        sums +=examination.sums
      end
    end unless @examinations.blank?
    hash["3"]=sums
    users.each do |user|
      @exams=Examination.find_by_sql("select count(e.types) sums,e.types from examinations e inner join exam_users  u on u.examination_id=e.id where u.user_id=#{user.id} and u.is_submited=1  group by types")
      hash1={}
      sums=0
      @exams.each do |exam|
        if exam.types.to_i==1||exam.types.to_i==0
          hash1["#{exam.types}"]=exam.sums
        else
          sums +=exam.sums
        end
      end unless @exams.blank?
      hash1["3"]=sums
      puts hash
      puts hash1
      simulation_belief=0
      num=Examination.find_by_sql("select count(e.id) ids from examinations e inner join exam_users  u on u.examination_id=e.id inner join papers p on p.id=u.paper_id  where u.user_id=#{user.id} and u.is_submited=1 and u.total_score>(p.total_score*0.6) and e.types=#{Examination::TYPES[:SIMULATION]}")[0].ids
      simulation_belief=0.5 if num==1
      simulation_belief=0.8 if num==2
      simulation_belief=1 if num>=3
      puts simulation_belief
      old_num=hash["#{Examination::TYPES[:OLD_EXAM]}"]*1.0
      unless old_num==0.0
        old_percent=hash1["#{Examination::TYPES[:OLD_EXAM]}"].nil? ? 0 :hash1["#{Examination::TYPES[:OLD_EXAM]}"]/old_num
      else
        old_percent=0
      end
      puts old_percent
      unless hash["#{Examination::TYPES[:PRACTICE1]}"].to_i==0
        collect_percent=hash1["#{Examination::TYPES[:PRACTICE1]}"].to_i/hash["#{Examination::TYPES[:PRACTICE1]}"].to_f
      else
        collect_percent=0
      end
      puts collect_percent
      url=Collection.find_by_user_id(user.id)
      if url
        doc= Document.new(File.open("f:/gankao/public"+url.collection_url ))
        n=0
        percent=0
        unless doc.elements["/collection/problems"].elements.size==0
          doc.elements["/collection/problems"].each_element do |problem|
            problem.elements["questions"].each_element do |question|
              percent += (100-question.attributes["error_percent"].to_i) unless question.attributes["error_percent"].nil?
              n +=1
            end
          end
          incorrect_percent=percent.to_f/n
        else
          incorrect_percent=1
        end
      else
        incorrect_percent=0
      end
      puts incorrect_percent
      sum=simulation_belief*0.5*(old_percent*0.3+ collect_percent*0.5+incorrect_percent*0.2)
      puts sum
      user.belief=sum.round()
      user.save
    end
  end
end

