module ApplicationHelper
   def title
    return @title.nil? ? "赶考" : @title
  end
end
