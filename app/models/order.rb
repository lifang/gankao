# encoding: utf-8
class Order< ActiveRecord::Base
  belongs_to :user
  VIP = {:YES => 1,:NO=>0}
end
