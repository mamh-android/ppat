module HomeHelper
    def get_task_scenarios(task_id)
        PowerRecord.find(:all, :conditions => ['task_id = ?', task_id], :select  => "distinct power_scenario_id")
    end

    def get_scenario_name(scenario_id)
        PowerScenario.find(:all, :conditions => ['id = ?', scenario_id])
    end

    def home_get_all_scenarios_info(image_date,platform,branch,device)
        PowerRecord.find(:all, :conditions => ['image_date = ? and platform = ? and branch = ? and device = ?', image_date, platform,branch,device])
    end

    def home_get_latest_image_date(image_date, platform, branch,device)
        PowerRecord.find(:first, :order => "image_date desc", :conditions => ['image_date < ? and platform = ? and branch = ?  and device = ?', image_date, platform,branch,device])
    end

    def home_get_scenario_info_by_id(scenario_id,image_date,platform,branch,device)
        PowerRecord.find(:all, :conditions => ['image_date = ? and platform = ? and branch = ? and power_scenario_id = ?  and device = ?', image_date, platform,branch, scenario_id,device])
    end

    def get_all_platform()
        PowerRecord.find(:all, :order => "platform desc", :select=>"distinct platform")
    end

    def get_all_branch(platform)
        PowerRecord.find(:all, :conditions =>['platform = ?',platform], :select => "distinct branch")
    end

    def get_all_device(platform)
        PowerRecord.find(:all, :conditions => ['platform = ?', platform], :select => "distinct device")
    end

    def get_all_data(platform,branch,device)
        PowerRecord.find(:all, :conditions => ['platform = ? and branch = ? and device =? ', platform,branch,device],:select => "distinct image_date")
    end
end
