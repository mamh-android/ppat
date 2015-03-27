class PowerScenario < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :power_records
end
