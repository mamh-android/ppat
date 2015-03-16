module OndemandHelper
    def get_task_scenarios(task_id)
        PowerRecord.where(task_id: task_id).group("power_scenario_id")
        #PowerRecord.find(:all, :conditions => ['task_id = ?', task_id], :group => "power_scenario_id")
    end

    def get_last_task_info()
        TaskInfo.where(run_type: "ondemand").last
    end

    def get_scenario_name(scenario_id)
        #PowerScenario.find(:all, :conditions => ['id = ?', scenario_id]).last.name
        PowerScenario.where(id: scenario_id).last.name
    end

    def get_scenario_name_category(name)
        PowerScenario.where(name:name).last.category
    end

    def get_scenario_name_com(category)
        PowerScenario.where(category: category).select("distinct name")
    end

    def get_task_id_purpose(task_id)
        PowerRecord.where(task_id:task_id)
    end

    def get_power_record_result(power_scenario_id,purpose,id,image_date)
        PowerRecord.where('power_scenario_id = ? and purpose = ? and id =? and image_date = ? ',power_scenario_id,purpose,id,image_date)
    end

    def get_scenario_info(scenario_id,task_id)
        PowerRecord.where('task_id = ? and power_scenario_id = ?', task_id, scenario_id)
        #PowerRecord.find(:all, :conditions => ['task_id = ? and power_scenario_id = ?', task_id, scenario_id])
    end

    def get_id(battery)
        PowerRecord.where(battery: battery)
    end

    def get_record_info(id)
      PowerRecord.find(id)
  end

end
