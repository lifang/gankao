#encoding: utf-8
require 'rubygems'
require 'google_chart'
require 'net/https'
require 'uri'
require 'open-uri'
namespace :charts do
  desc "create picture "
  task(:create_picture => :environment) do
    top_member = 100
    y_axis_labels = (0..10).to_a.collect do |v|
      val = (top_member.to_i/10)  * v
      if val == 0  or  val == top_member/2 or val == top_member
        val.to_s
      else
        nil
      end
    end
    
    x_axis_labels = (1..31).to_a.collect do |v|
      if [1,8,15,22,29].member?(v)
        "11-20"
      end
    end

    series_1_xy = []
    series_1_xy[1] = [1, 9]
    series_1_xy[2] = [2, 8]
    series_1_xy[3] = [3, 7]
    series_1_xy[4] = [4, 6]
    series_1_xy[5] = [5, 9]
    series_1_xy[6] = [6, 7]
    series_1_xy[7] = [7, 3]
    series_1_xy[8] = [8, 6]

    lc = GoogleChart::LineChart.new('320x200', "", true)
    lc.data "belief", [[1,5],[2,6],[3,7],[4,5],[5,4],[6,8],[7,1],[8,2],[9,4]], '0000ff'
    lc.max_value [10,10]
    lc.axis :y, :labels => [0,1,2,3,4,5,6,7,8,9,10]
    lc.axis :x, :labels => [0,1,2,3,4,5,6,7,8,9,10]
    lc.data_encoding = :text
    lc.show_legend = false
    lc.grid :x_step => 10, :y_step => 10, :length_segment => 1, :length_blank => 3
    write_img(URI.escape(lc.to_url))
  end

  def write_img(url)  #上传图片
    all_dir = ""
    open(url) do |fin|
      date = Time.now.strftime("%Y%m%d")
      file_name ="k#{date}.jpg"
      all_dir = "#{File.expand_path(Rails.root)}/public/beliefs/"
      unless File.directory?(all_dir)
        Dir.mkdir(all_dir)
      end
      File.open("#{all_dir}#{file_name}", "wb+") do |fout|
        while buf = fin.read(1024) do
          fout.write buf
        end
      end
    end

  end
end

