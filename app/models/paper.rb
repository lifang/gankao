class Paper < ActiveRecord::Base

  require 'rexml/document'
  include REXML

  has_many :paper_blocks ,:dependent=>:destroy
  has_many :examination_paper_relations,:dependent=>:destroy
  has_many :examinations, :through=>:examination_paper_realations, :source => :examination
  belongs_to :user,:foreign_key=>"creater_id"
  belongs_to :category
  has_many :exam_users

  default_scope :order => "papers.created_at desc"

  #更新试卷基本信息
  def update_base_info(url, options = {})
    doc=Document.new(File.open(url))
    doc.root.elements["base_info"].elements["updated_at"].text=Time.now.strftime("%Y-%m-%d %H:%M")
    doc.root.elements["base_info"].elements["title"].text=self.title
    doc.root.elements["base_info"].elements["description"].text=self.description
    options.each do |key, value|
      doc.root.elements["base_info"].elements["#{key}"].text = value
    end unless options.empty?
    file=File.open(url,"w+")
    file.write(doc)
    file.close
  end

  #创建试卷的文件
  def create_paper_url(str, path, file_type)
    dir = "#{Rails.root}/public" 
    unless File.directory?(dir + "/" + path)
      Dir.mkdir(dir + "/" + path)
    end
    file_name = "/" + path + "/#{self.id}." + file_type
    url = dir + file_name
    f=File.new(url,"w")
    f.write("#{str.force_encoding('UTF-8')}")
    f.close
    if file_type == "xml"
      self.paper_url = file_name
    else
      self.paper_js_url = file_name
    end
    self.save
  end

  #创建xml文件
  def xml_content(options = {})
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    content += <<-XML
      <paper id='#{self.id}' total_num='0' total_score='0'>
        <base_info>
          <title>#{self.title.force_encoding('ASCII-8BIT')}</title>
          <category>#{self.category_id}</category>
          <creater>#{self.creater_id}</creater>
          <created_at>#{self.created_at.strftime("%Y-%m-%d %H:%M").force_encoding('ASCII-8BIT')}</created_at>
          <updated_at>#{self.updated_at.strftime("%Y-%m-%d %H:%M").force_encoding('ASCII-8BIT')}</updated_at>
          <description>#{self.description.force_encoding('ASCII-8BIT')}</description>
    XML
    options.each do |key, value|
      content+="<#{key}>#{value.force_encoding('ASCII-8BIT')}</#{key}>"
    end unless options.empty?
    content += <<-XML
      </base_info>
      <blocks>
      </blocks>
      </paper>
    XML
    return content
  end

  #置试卷的使用状态
  def set_paper_used!
    self.toggle!(:is_used)
  end

  def Paper.search_mothod(user_id, start_at, end_at, title, category, per_page, page, options={})
    sql = "select * from papers where creater_id=#{user_id}"
    sql += " and created_at > '#{start_at}'" unless start_at.nil?
    sql += " and created_at < '#{end_at}'" unless end_at.nil?
    sql += " and title like '%#{title}%'" unless title.nil?
    sql += " and category_id = #{category}" unless category.nil?
    options.each do |key, value|
      sql += " and #{key} #{value} "
    end unless options.empty?
    sql += " order by created_at desc"
    puts sql
    return Paper.paginate_by_sql(sql, :per_page =>per_page, :page => page)
  end

  #生成试卷的json
  def create_paper_js
    doc = Document.new(File.open "#{Constant::PUBLIC_PATH}/#{self.paper_url}")
    doc.root.elements["blocks"].each_element do |block|
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          question.delete_element(question.elements["answer"])
          question.delete_element(question.elements["analysis"])
        end
      end
    end
    return "papers = " + Hash.from_xml(doc.to_s).to_json
  end

  #更新试卷的题目数和总分
  def update_num_score
    doc = Document.new(File.open "#{Constant::PUBLIC_PATH}/#{self.paper_url}")
    self.total_score = doc.root.attributes["total_score"].to_i
    self.total_question_num = doc.root.attributes["total_num"].to_i
    self.save
  end

end
