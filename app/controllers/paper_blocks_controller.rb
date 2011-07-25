class PaperBlocksController < ApplicationController

  require 'rexml/document'
  include REXML

  def load_create_problem
    paper_id = params[:paper_id]
    block_id = params[:block_id]
    file = File.new("#{Constant::PAPER_PATH}/#{paper_id.to_i}.xml","r+")
    @xml = REXML::Document.new(file).root
    block = @xml.elements["blocks"].elements["block[@id='#{block_id}']"]
    if params[:type] == "create"
      render :partial =>"/papers/new_question",:object=>block
    else
      render :partial =>"/papers/mavin_question",:object=>block
    end
  end


  def load_edit_problem
    paper_id = params[:paper_id]
    block_id = params[:block_id]
    problem_id = params[:problem_id] 
    file = File.new("#{Constant::PAPER_PATH}/#{paper_id.to_i}.xml","r+")
    @xml = REXML::Document.new(file).root
    problem = @xml.elements["blocks"].elements["block[@id='#{block_id}']"]
        .elements["problems"].elements["problem[@id='#{problem_id}']"]
    render :partial => "/papers/edit_problem",:object => problem
  end

  def choose_type
    @block_id = params[:id]
    @paper_id = params[:paper_id]
    @problem_type = params[:problem_type].to_i
    @question_type = params[:question_type].to_i
    if @question_type == Problem::QUESTION_TYPE[:SINGLE_CHOSE]
      render :partial => "/common/single_choose"
    elsif @question_type == Problem::QUESTION_TYPE[:MORE_CHOSE]
      render :partial => "/common/more_choose"
    elsif @question_type == Problem::QUESTION_TYPE[:JUDGE]
      render :partial => "/common/judge"
    elsif @question_type == Problem::QUESTION_TYPE[:SINGLE_CALK]
      render :partial => "/common/fill_blank"
    elsif @question_type == Problem::QUESTION_TYPE[:COLLIGATION]
      render :partial => "/common/colligation"
    else 
      render :partial => "/common/fill_blank"
    end

  end

  def destroy
    @block = PaperBlock.find(params[:id].to_i)
    @block.delete_block_xml
    @block.destroy
    redirect_to request.referer
  end
  
  
end
