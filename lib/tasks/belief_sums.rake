#encoding:utf-8
require 'rexml/document'
include REXML
namespace :belief do
  desc "rate paper"
  task(:sums => :environment) do
    @examinations = Examination.find_by_sql("select count(types) sums, types from examinations
      where is_published = #{Examination::IS_PUBLISHED[:ALREADY]}
      and types != #{Examination::TYPES[:SIMULATION]} group by types")
    users = User.find_by_sql("select u.id from users u inner join orders o where u.id = o.user_id ")
    hash = {}
    @examinations.each do |examination|
      hash["#{examination.types}"] = examination.sums
    end unless @examinations.blank?
    users.each do |user|
      @exams = Examination.find_by_sql("select count(types) sums,e.types from examinations e
        inner join exam_users u on u.examination_id = e.id
        where e.types != #{Examination::TYPES[:SIMULATION]} and u.is_submited = #{ExamUser::IS_SUBMITED[:YES]}
        and u.user_id = #{user.id} group by types")
      hash1={}
      @exams.each do |exam|
        hash1["#{exam.types}"]=exam.sums
      end unless @exams.blank?
      simulation_belief = 0
      num = Examination.find_by_sql("select count(e.id) ids from examinations e 
        inner join exam_users  u on u.examination_id = e.id inner join papers p on p.id = u.paper_id
        where u.is_submited = #{ExamUser::IS_SUBMITED[:YES]} and e.types=#{Examination::TYPES[:SIMULATION]}
        and u.user_id = #{user.id} and u.total_score > (p.total_score*0.6) ")
      if num and num[0]
        simulation_belief = 0.5 if num[0].ids == 1
        simulation_belief = 0.8 if num[0].ids == 2
        simulation_belief = 1 if num[0].ids == 3
      end
      puts simulation_belief
      old_percent = 0
      old_percent = hash1["#{Examination::TYPES[:OLD_EXAM]}"].to_f/hash["#{Examination::TYPES[:OLD_EXAM]}"] unless
      hash["#{Examination::TYPES[:OLD_EXAM]}"].nil? or hash["#{Examination::TYPES[:OLD_EXAM]}"] == 0
      puts old_percent
      collect_percent = 0
      collect_percent=hash1["#{Examination::TYPES[:PRACTICE]}"].to_f/hash["#{Examination::TYPES[:PRACTICE]}"] unless
      hash["#{Examination::TYPES[:PRACTICE]}"].nil? or hash["#{Examination::TYPES[:PRACTICE]}"] == 0
      puts collect_percent
      collection = Collection.find_by_user_id(user.id)
      incorrect_percent = 0
      if collection and collection.collection_url
        doc = Document.new(File.open(Constant::PUBLIC_PATH + collection.collection_url ))
        n = 0
        percent = 0
        incorrect_percent = 1
        doc.elements["/collection/problems"].each_element do |problem|
          problem.elements["questions"].each_element do |question|
            percent += question.attributes["error_percent"].to_i unless question.attributes["error_percent"].nil?
            n +=1
          end
        end
        incorrect_percent = percent.to_f/n/100 if percent != 0 and n != 0
      end
      puts incorrect_percent
      sum = (simulation_belief) * ((old_percent*0.3 + collect_percent*0.5 + incorrect_percent*0.2)*100)
      puts sum
      user_belief = UserBelief.find_by_user_id_and_created_at(user.id, Time.now.to_date)
      UserBelief.create(:user_id => user.id,:belief => sum.round) unless user_belief
      puts "#{user.id}success"
    end
  end
end

