class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  def write_xml(url,doc)
    file = File.new(url, "w+")
    file.write(doc)
    file.close
  end
end
