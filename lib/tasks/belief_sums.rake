#encoding:utf-8
require 'rexml/document'
require 'rake'
include REXML
namespace :belief do
  desc "rate paper"
  task(:sums => :environment) do
    @examinations=Examination.find_by_sql("select count(types) sums,types from examinations group by types")
    users=User.find_by_sql("select u.belief,u.id from users u inner join orders o where u.id=o.user_id ")
    puts users.class
    users.each do |user|
      @exams=Examination.find_by_sql("select count(e.types) sums,e.types from examinations e inner join exam_users  u on u.examination_id=e.id where u.user_id=#{user.id} and u.is_submited=1  group by types")
      hash={}
      @examinations.each do |examination|
        hash["#{examination.types}"]=[examination.sums,0]
        @exams.each do |exam|
          if examination.types==exam.types
            hash["#{examination.types}"]=[examination.sums,exam.sums]
            break
          end
        end unless @exams.blank?
      end unless @examinations.blank?
      puts hash
      simulation_belief=1
      num=hash["#{Examination::TYPES[:SIMULATION]}"][1]*1.0
      simulation_belief=0.5 if num==1
      simulation_belief=0.8 if num==2
      puts simulation_belief
      old_num=hash["#{Examination::TYPES[:OLD_EXAM]}"][0]*1.0
      unless old_num==0
        old_percent=hash["#{Examination::TYPES[:OLD_EXAM]}"][1]*1.0/old_num
      else
        old_num=0
      end
      puts old_percent
      collection_num=(hash["#{Examination::TYPES[:PRACTICE1]}"][0]+hash["#{Examination::TYPES[:PRACTICE2]}"][0]+hash["#{Examination::TYPES[:PRACTICE3]}"][0]+hash["#{Examination::TYPES[:PRACTICE3]}"][0]+hash["#{Examination::TYPES[:PRACTICE4]}"][0])*1.0
      user_collection_num=(hash["#{Examination::TYPES[:PRACTICE1]}"][1]+hash["#{Examination::TYPES[:PRACTICE2]}"][1]+hash["#{Examination::TYPES[:PRACTICE3]}"][1]+hash["#{Examination::TYPES[:PRACTICE3]}"][1]+hash["#{Examination::TYPES[:PRACTICE4]}"][1])*1.0
      unless collection_num==0
        collect_percent=user_collection_num/collection_num
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
              percent +=question.attributes["correct_percent"].split("%")[0].to_f/100 unless question.attributes["correct_percent"].nil?
              n +=1
            end
          end
          incorrect_percent=percent/n
        else
          incorrect_percent=1
        end
      else
        incorrect_percent=0
      end
      puts incorrect_percent
      sum=simulation_belief*0.5*(old_percent*0.3+ collect_percent*0.5+incorrect_percent*0.2)
      puts sum
      user.belief=((sum*100)+0.5).to_i
      user.save
    end
  end
end

