module QueryHelper
	def remove_from_queue(uuid)
		Resque::Plugins::Status::Hash.remove(uuid)
	end
end