class Cart < ActiveRecord::Base
  has_many :record_list, :dependent => :destroy
  attr_accessible :record_list
end
