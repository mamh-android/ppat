module HomeHelper
    def get_task_scenarios(task_id)
        #PowerRecord.where(:all, :conditions => ['task_id = ?', task_id], :select  => "distinct power_scenario_id")
    PowerRecord.where(['task_id = ?', task_id]).select("distinct power_scenario_id")
    end


    def home_get_all_scenarios_info(image_date,branch,device)
        PowerRecord.where(['image_date = ? and branch = ? and device = ? and run_type = ?', image_date,branch,device, "daily"])
    end

    def home_get_scenario_info(image_date,branch,device, scenario_id)
        PowerRecord.where(['image_date = ? and branch = ? and device = ? and run_type = ? and power_scenario_id = ?', image_date,branch,device, "daily", scenario_id])
    end

    def home_get_latest_image_date(image_date, branch,device)
            PowerRecord.where(['image_date < ? and branch = ?  and device = ? and run_type = ?', image_date,branch,device, "daily"]).order("image_date").last
    end

    def home_get_scenario_info_by_id(scenario_id,image_date,branch,device)
        PowerRecord.where(['image_date = ? and branch = ? and power_scenario_id = ?  and device = ? and run_type = ?', image_date, branch, scenario_id,device, "daily"]).last
    end

    def get_all_platform()
        PowerRecord.order("platform desc").select("distinct platform")
    end

    def get_all_branch(platform)
        if platform == "pxa1928"
            platform = "eden"
        elsif platform == "pxa1928ff"
            platform = "edeff"
        elsif platform == "pxa1936"
            platform = "hln3"
        elsif platform = "pxa1936ff"
            platform = "hln3ff"
        elsif platform = "pxa1908"
            platform = "ulc1"
        elsif platform = "pxa1908ff"
            platform = "ulc1ff"
        end
        #PowerRecord.where(['platform = ?',platform], :select => "distinct branch")
    PowerRecord.where(platform: platform, run_type: "daily").select("distinct branch")
    end

    def get_all_device(platform)
        if platform == "pxa1928"
            platform = "eden"
        elsif platform == "pxa1928ff"
            platform = "edeff"
        elsif platform == "pxa1936"
            platform = "hln3"
        elsif platform = "pxa1936ff"
            platform = "hln3ff"
        elsif platform = "pxa1908"
            platform = "ulc1"
        elsif platform = "pxa1908ff"
            platform = "ulc1ff"
        end
        #PowerRecord.where(['platform = ?', platform], :select => "distinct device")
    PowerRecord.where(platform: platform, run_type: "daily").select("distinct device")
    end

    def get_all_data(branch,device)
        #PowerRecord.where(['platform = ? and branch = ? and device =? ', platform,branch,device],:select => "distinct image_date")
    PowerRecord.where(['branch = ? and device =?  and run_type = ?',branch,device, "daily"]).select("distinct image_date")
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
    def get_username_id(id)
        User.where(id:id)
    end

    def get_username(email_addr)
        User.where(email_addr: email_addr)
    end

    def comment_date(platform,branch,device);
        CommentRecord.where('platform = ? and branch = ? and device = ?',platform,branch,device).select("distinct uploadtime")
    end

end
