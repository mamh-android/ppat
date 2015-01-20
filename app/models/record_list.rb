class RecordList < ActiveRecord::Base
  #attr_accessible :cart_id, :power_record_id, :power_record
  belongs_to :power_record
  belongs_to :cart
end
