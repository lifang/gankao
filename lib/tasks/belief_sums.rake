#encoding:utf-8
require 'rexml/document'
require 'rake'
include REXML
namespace :belief do
  desc "rate paper"
  task(:sums => :environment) do
    users=User.find_by_sql("select u.belief,u.id from users u inner join orders o where u.id=o.user_id ")
    users.each do |user|
      simulation_belief=1
      num=ExamUser.find_by_sql("select count(e.id) sum from examinations  e left join exam_users u on u.examination_id=e.id where
                                 e.types=#{Examination::TYPES[:SIMULATION]} and u.user_id=#{user.id} ")[0].sum*1.0
      simulation_belief=0.5 if num==1
      simulation_belief=0.8 if num==2
      puts simulation_belief
      old_percent=ExamUser.find_by_sql("select count(e.id) sum from examinations  e left join exam_users u on u.examination_id=e.id where 
                                  e.types=#{Examination::TYPES[:OLD_EXAM]} and u.user_id=#{user.id} ")[0].sum*1.0/ExamUser.find_by_sql("select count(e.id) sum from examinations  e left join exam_users u on u.examination_id=e.id where 
                                  e.types=#{Examination::TYPES[:OLD_EXAM]} ")[0].sum*1.0
      puts old_percent
      collect_percent=ExamUser.find_by_sql("select count(e.id) sum from examinations  e left join exam_users u on u.examination_id=e.id where 
                                  e.types in (2,3,4,5,6) and u.user_id=#{user.id}")[0].sum*1.0/ExamUser.find_by_sql("select count(e.id) sum from examinations  e left join exam_users u on u.examination_id=e.id where 
                                  e.types in (2,3,4,5,6)")[0].sum*1.0
      puts collect_percent
      url=Collection.find_by_user_id(user.id)
      if url
        doc= Document.new(File.open("f:/gankao/public"+url.collection_url ))
        n=0
        percent=0
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
      puts incorrect_percent
      sum=simulation_belief*0.5*(old_percent*0.3+ collect_percent*0.5+incorrect_percent*0.2)
      puts sum
      puts ((sum*100)+0.5).to_i
      puts "end"
      user.belief=((sum*100)+0.5).to_i
      user.save
    end
  end
end

