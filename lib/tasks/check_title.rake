# encoding: utf-8
require 'rexml/document'
include REXML
namespace :check do
  desc "rate paper"
  task(:title => :environment) do
    file_path="f:/exam_app/public/papers"
    def traverse_dir(file_path)
      if File.directory? file_path
        Dir.foreach(file_path) do |file|
          if file!="." and file!=".."
            traverse_dir(file_path+"/"+file){|x| yield x}
          end
        end
      else
        yield  file_path
      end
    end
    def write_xml(url,doc)
      file = File.new(url, "w+")
      file.write(doc)
      file.close
    end
    def modify_tag(block,type)
      block.get_elements("problems//questions/question").each do |question|
        question.elements["tags"].text="#{question.elements["tags"].text} #{type}" unless question.elements["tags"].text=~ /#{type}/
      end
    end

    traverse_dir(file_path){|f|
      if f.to_s() =~ /\.xml$/
        doc= REXML::Document.new(File.new(f)).root
        NUM=0
        doc.elements["blocks"].each_element do |block|
          NUM +=1
          title=block.elements["base_info/title"].text
          if title=~ /writing/
            modify_tag(block,"写作",doc,f)
          elsif title=~ /reading comprehension/&& NUM==2
            modify_tag(block,"快速阅读",doc,f)
          elsif title=~ /reading comprehension/&& NUM==4
            modify_tag(block,"阅读",doc,f)
          elsif title=~ /listening comprehension/
            modify_tag(block,"听力",doc,f)
          elsif title=~ /translation/
            modify_tag(block,"翻译",doc,f)
          elsif title=~ /cloze/
            modify_tag(block,"完形填空",doc,f)
          end
        end
        js_file=Hash.from_xml(doc.to_s).to_json
        write_xml("f:/exam_app/public/paperjs/#{doc.attributes['id']}.js","papers = "+js_file)
        write_xml(file_path,doc)
      end
    }
  end
end

