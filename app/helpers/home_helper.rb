module HomeHelper
    def get_task_scenarios(task_id)
        PowerRecord.find(:all, :conditions => ['task_id = ?', task_id], :group => "power_scenario_id")
    end

    def get_scenario_name(scenario_id)
        PowerScenario.find(:all, :conditions => ['id = ?', scenario_id])
    end

    def home_get_all_scenarios_info(image_date,platform,branch)
        PowerRecord.find(:all, :conditions => ['image_date = ? and platform = ? and branch = ?', image_date, platform,branch])
    end

    def home_get_latest_image_date(image_date, platform, branch)
        PowerRecord.find(:first, :order => "image_date desc", :conditions => ['image_date < ? and platform = ? and branch = ?', image_date, platform,branch])
    end

    def home_get_scenario_info_by_id(scenario_id,image_date,platform,branch)
        PowerRecord.find(:all, :conditions => ['image_date = ? and platform = ? and branch = ? and power_scenario_id = ?', image_date, platform,branch, scenario_id])
    end
end
