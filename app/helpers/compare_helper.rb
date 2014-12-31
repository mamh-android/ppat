require 'set'
module CompareHelper
	#get distinct purpose
	def get_distinct_purposes()
		@cart = get_cart
		@purposes = Set.new
		@cart.record_list.each do |record|
			@purposes.add get_record_info(record.power_record.id).purpose
		end
		@purposes
	end

	#get distinct scenarios
	def get_distinct_scenario_categories()
		@cart = get_cart
		@categories = Set.new
		@cart.record_list.each do |record|
			@categories.add get_scenario_category(record.power_record.power_scenario_id)
		end
		@categories.to_a
	end

	def get_scenario_category(scenario_id)
		PowerScenario.find(:all, :conditions => ['id = ?', scenario_id]).last.category
	end

end
