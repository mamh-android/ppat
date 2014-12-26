class User < ActiveRecord::Base
    has_many :task_info
end
