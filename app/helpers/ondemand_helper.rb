module OndemandHelper
	def get_task_scenarios(task_id)
		PowerRecord.find(:all, :conditions => ['task_id = ?', task_id], :group => "power_scenario_id")
	end

	def get_scenario_name(scenario_id)
		PowerScenario.find(:all, :conditions => ['id = ?', scenario_id]).last.name
	end

	def get_scenario_info(scenario_id,task_id)
		PowerRecord.find(:all, :conditions => ['task_id = ? and power_scenario_id = ?', task_id, scenario_id])
	end

	def get_record_info(id)
      PowerRecord.find(id)
  end

end
