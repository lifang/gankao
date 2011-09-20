#encoding: utf-8
require 'rubygems'
require 'google_chart'
require 'net/https'
require 'uri'
require 'open-uri'
namespace :charts do
  desc "create picture "
  task(:create_picture => :environment) do
    users = User.find_by_sql("select u.* from users u inner join orders o where u.id = o.user_id ")
    users.each do |user|
      x_axis_labels = []
      xy_axis_labels = []
      max_x = 0
      xy_axis = {}
      user_beliefs = UserBelief.find_by_sql(["select * from user_beliefs where user_id = ? order by created_at desc limit 8",
          user.id])
      start_month = 0
      user_beliefs.each do |belief|
        create_day = belief.created_at.day
        start_month = belief.created_at.month unless belief.created_at.month == start_month
        if [1, 8, 15, 22, 29].include?(create_day)
          x_label = (belief.created_at.strftime("%Y%m%d").to_s)[4, 8]
          x_axis_labels << x_label
          xy_axis[x_label.to_i] = belief.belief.to_i
          max_x = x_label.to_i if x_label.to_i > max_x
        end
      end
      x_axis = x_axis_labels.sort
      step =  (x_axis_labels.length-1 > 0) ? max_x/(x_axis_labels.length-1) : max_x
      x_labels = []
      x_axis.each_with_index do |item, index|
        x_labels << "#{item[0, 2]}/#{item[2, 3]}"
        xy_axis_labels << [index * step, xy_axis[item.to_i]]
      end
      begin
        lc = GoogleChart::LineChart.new('240x150', "", true)
        lc.data "belief", xy_axis_labels, '458B00'
        lc.max_value [max_x,100]
        lc.axis :x, :labels => x_labels
        lc.axis :y, :labels => ["0pct", "20pct", "40pct", "60pct", "80pct", "100pct"]
        lc.data_encoding = :text
        lc.show_legend = false
        write_img(URI.escape(lc.to_url({:chm => "o,0066FF,0,-1,6"})), user)
        puts lc.to_url({:chm => "o,0066FF,0,-1,6"})
      rescue
        puts "web lost"
      end
    end
  end

  def write_img(url, user)  #上传图片
    all_dir = ""
    file_name ="k#{user.id}.jpg"
    all_dir = "#{File.expand_path(Rails.root)}/public/beliefs/#{user.id}/"
    unless File.directory?(all_dir)
      Dir.mkdir(all_dir)
    end
    open(url) do |fin|
      File.open("#{all_dir}#{file_name}", "wb+") do |fout|
        while buf = fin.read(1024) do
          fout.write buf
        end
      end
    end
    user.update_attributes(:belief_url => "/beliefs/#{user.id}/#{file_name}")
  end
end

