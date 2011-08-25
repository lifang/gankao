# encoding: utf-8
require 'rexml/document'
require 'rake'
include REXML
namespace :belief do
  desc "rate paper"
  task(:sums => :environment) do                                             
    user =User.find(cookies[:user_id])
    simulation_belief=0
    def return_sum(types,user)
      sql="select count(e.id) sum from examinations  e left join exam_users u on u.examination_id=e.id where 1=1"
      if types.to_s.length==1
        sql += " and e.types=#{types}"
      else
        sql += " and e.types in (#{types})"
      end
      sql += " and u.user_id=#{cookies[:user_id]}" if user==1
      return ExamUser.find_by_sql(sql)[0].sum*1.0
    end
    num=return_sum(Examination::TYPES[:SIMULATION],1).to_i
    simulation_belief=0.5 if num >=1
    simulation_belief=0.8 if num>=2
    simulation_belief=1 if num>=3
    puts simulation_belief
    old_percent=return_sum(Examination::TYPES[:OLD_EXAM],1)/return_sum(Examination::TYPES[:OLD_EXAM],0)
    puts 4.0/7
    puts old_percent
    collect_percent=return_sum("2,3,4,5,6",1)/return_sum("2,3,4,5,6",0)
    puts collect_percent
    doc=Collection.find_by_user_id(1).open_xml
    n=0
    percent=0
    doc.elements["/collection/problems"].each_element do |problem|
      problem.elements["questions"].each_element do |question|
        percent +=question.attributes["correct_percent"].split("%")[0].to_f/100 unless question.attributes["correct_percent"].nil?
        n +=1
      end
    end
    incorrect_percent=percent/n
    puts incorrect_percent
    sum=simulation_belief*0.5*(old_percent*0.3+ collect_percent*0.5+incorrect_percent*0.2)
    puts sum
    user.belief=(sum*100).to_i
    user.save
    puts (sum*100).to_i
  end
end

