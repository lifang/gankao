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
      user_beliefs = UserBelief.find_all_by_user_id(user.id)
      start_month = 0
      user_beliefs.each do |belief|
        create_day = belief.created_at.day
        start_month = belief.created_at.month unless belief.created_at.month == start_month
        if [1, 8, 15, 22, 29].include?(create_day)
          if create_day == 1
            #x_label = (belief.created_at.strftime("%Y%m%d").to_s)[2, 6]
            x_label = (belief.created_at.strftime("%Y%m%d").to_s)[4, 8]
          else
            if belief.created_at.month == start_month
              x_label = (belief.created_at.strftime("%Y%m%d").to_s)[4, 8]
            else
              #x_label = (belief.created_at.strftime("%Y%m%d").to_s)[2, 6]
              x_label = (belief.created_at.strftime("%Y%m%d").to_s)[4, 8]
            end
          end
          x_axis_labels << x_label.to_i
          xy_axis_labels << [x_label.to_i, belief.belief.to_i]
        end
      end
      puts "#{xy_axis_labels}"
      begin
      lc = GoogleChart::LineChart.new('320x200', "", true)
      lc.data "belief", xy_axis_labels, '458B00'
      if x_axis_labels.length >= 8
        max_axis_x = x_axis_labels.sort.last
      else
        max_axis_x = 1229
        x_axis_labels << [1229]
      end
      lc.max_value [max_axis_x,100]
      lc.axis :y, :labels => [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
      lc.axis :x, :labels => x_axis_labels
      lc.data_encoding = :text
      lc.show_legend = false
#      lc.grid :x_step => 8, :y_step => 10, :length_segment => 1, :length_blank => 3
      write_img(URI.escape(lc.to_url), user)
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

