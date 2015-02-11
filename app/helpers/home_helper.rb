module HomeHelper
    def get_task_scenarios(task_id)
        #PowerRecord.where(:all, :conditions => ['task_id = ?', task_id], :select  => "distinct power_scenario_id")
    PowerRecord.where(['task_id = ?', task_id]).select("distinct power_scenario_id")
    end

    def get_scenario_name(scenario_id)
    PowerScenario.where(id: scenario_id).order("id").last
    end

    def home_get_all_scenarios_info(image_date,platform,branch,device)
        PowerRecord.where(['image_date = ? and platform = ? and branch = ? and device = ?', image_date, platform,branch,device])
    end

    def home_get_latest_image_date(image_date, platform, branch,device)
            PowerRecord.where(['image_date < ?  and platform = ? and branch = ?  and device = ?', image_date, platform,branch,device]).order("image_date").last
    end

    def home_get_scenario_info_by_id(scenario_id,image_date,platform,branch,device)
        PowerRecord.where(['image_date = ? and platform = ? and branch = ? and power_scenario_id = ?  and device = ?', image_date, platform,branch, scenario_id,device])
    end

    def get_all_platform()
        PowerRecord.order("platform desc").select("distinct platform")
    end

    def get_all_branch(platform)
        #PowerRecord.where(['platform = ?',platform], :select => "distinct branch")
    PowerRecord.where(['platform = ?',platform]).select("distinct branch")
    end

    def get_all_device(platform)
        #PowerRecord.where(['platform = ?', platform], :select => "distinct device")
    PowerRecord.where(['platform = ?', platform]).select("distinct device")
    end

    def get_all_data(platform,branch,device)
        #PowerRecord.where(['platform = ? and branch = ? and device =? ', platform,branch,device],:select => "distinct image_date")
    PowerRecord.where(['platform = ? and branch = ? and device =? ', platform,branch,device]).select("distinct image_date")
    end

    def get_all_code_drop(platform)
    PlatformBranch.where(['platform = ?', platform])
    end

    def get_all_code_drop_user(platform_branch_id)
    CodeDrop.where(['platform_branch_id = ?', platform_branch_id])
    end

    def get_all_platformbranch()
       PlatformBranch.order("platform desc").select("distinct platform")
    end
end
