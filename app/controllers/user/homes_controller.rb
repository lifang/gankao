#encoding: utf-8
class User::HomesController < ApplicationController
  before_filter :access?
  layout "gankao"

  def show
    @simulations = Examination.find_by_sql("select * from examinations where types = #{Examination::TYPES[:SIMULATION]}
      and is_published = #{Examination::IS_PUBLISHED[:ALREADY]} and category_id = #{params[:id].to_i} order by created_at")
    @hash1 = Examination.exam_users_hash(cookies[:user_id], Examination::TYPES[:SIMULATION], params[:id].to_i)
    @simulations.each do |simulation|
      @simulations = @simulations - [simulation] if (!@hash1.keys.include?(simulation.id.to_s) and
          simulation.status == Examination::STATUS[:CLOSED])
    end unless @hash1.empty?
    @all_examinations = Examination.find_by_sql("select count(types) sums, types from examinations
      where is_published = #{Examination::IS_PUBLISHED[:ALREADY]} and category_id = #{params[:id].to_i}
      and types != #{Examination::TYPES[:SIMULATION]} group by types")
    @user_exams = Examination.find_by_sql("select count(types) sums,e.types from examinations e
      inner join exam_users u on u.examination_id = e.id
      where e.types != #{Examination::TYPES[:SIMULATION]} and category_id = #{params[:id].to_i}
      and u.is_submited = #{ExamUser::IS_SUBMITED[:YES]}
      and u.user_id = #{cookies[:user_id]} group by types")
    @type_hash = {}
    @all_examinations.each do |examination|
      @type_hash["#{examination.types}"]=[examination.sums, 0]
      @user_exams.each do |exam|
        if examination.types == exam.types
          @type_hash["#{examination.types}"] = [examination.sums, exam.sums]
          break
        end
      end unless @user_exams.blank?
    end
    @correct = Examination.count_correct(cookies[:user_id],params[:id].to_i)
    collection = Collection.find_by_user_id(cookies[:user_id])
    begin
      @incorrect_list = collection.open_xml.root if collection and collection.collection_url
      note = Note.find_by_user_id(cookies[:user_id])
      @notes = note.open_xml.root if note and note.note_url
    rescue
    end
  end
  
end
