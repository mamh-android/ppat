class TaskInfo < ActiveRecord::Base
  #attr_accessible :user_id, :task_id
  belongs_to :user
end
