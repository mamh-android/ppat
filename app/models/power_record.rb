class PowerRecord < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope
  has_many :record_list
  has_many :task_info
end
