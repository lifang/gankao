class Trouble < ActiveRecord::Base
  belongs_to:exam_user
  belongs_to:problem
end
