class Cart < ActiveRecord::Base
  has_many :record_list, :dependent => :destroy
end
