class Cart < ActiveRecord::Base
  has_many :record_list, :dependent => :destroy
  accepts_nested_attributes_for :record_list
  #attr_accessible :record_list
end
