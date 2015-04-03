require 'set'
class QueryController < ApplicationController
  def index
  	@queues = get_distinct_queues(Resque::Plugins::Status::Hash.statuses)
  	render :layout=>"ppat"
  end

  def delete_job
  	uuid = params[:uuid]
  	Resque::Plugins::Status::Hash.remove(uuid)
  	redirect_to "/query/index"
  end

  def update_queue
  	uuid = params[:uuid]
  	status = Resque::Plugins::Status::Hash.get(uuid)
  	Resque::Plugins::Status::Hash.remove(uuid)
  	platform = status.options['platform']
  	if platform == 'helan3'
  		TriggerHelan3Job.create(status.options)
  	elsif platform == 'ulc1'
  		TriggerULC1Job.create(status.options)
  	else
  		TriggerEdenJob.create(status.options)
  	end
  	redirect_to "/query/index"
  end
private
	def get_distinct_queues(all)
		queues = Hash.new
		all.each do |hash|
			platform = hash.options["platform"]
			queue = queues[platform]
			if queue.nil?
				queue = Set.new
			end
			queue.add hash
			queues[platform] = queue
		end
		queues
	end
end
