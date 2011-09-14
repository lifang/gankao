#encoding: utf-8
class Feedback < ActiveRecord::Base
  belongs_to:user
  belongs_to:question
end