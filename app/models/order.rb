# encoding: utf-8
class Order< ActiveRecord::Base
  belongs_to :user
end