module DailyHelper
    def get_daily_power(image_date, scenario_id, device, branch)
        PowerRecord.where('image_date = ? and power_scenario_id = ? and device = ? and branch = ? and is_show = ? and run_type = ?', image_date, scenario_id, device, branch, "1", "daily")
    end
    def get_last_power(image_date, scenario_id, device, branch)
        #Helnconsumption.find(:all, :conditions => ['image_date = ? and scenario_id = ? and verify = ?', image_date, scenario_id, "P"]).last
        PowerRecord.where('image_date = ? and power_scenario_id = ? and device = ? and branch = ? and is_show = ? and run_type = ?', image_date, scenario_id, device, branch, "1", "daily").last
    end

    def get_display_image_dates(device, branch)
        PowerRecord.where("device = ? AND branch = ? and run_type =  ? and is_show = ?", device, branch, "daily", "1").select("distinct image_date").order("image_date desc").limit(15)
    end

    def get_display_scenarios_id(device, branch, image_start, image_end)
        PowerRecord.where("branch = ? and device = ? and is_show = 1 and image_date BETWEEN ? AND ? ", branch, device, image_start, image_end).select("group_concat(distinct power_scenario_id) as list").last.list
    end

    def get_display_records(image_start, image_end, branch, device)
        PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ? and run_type =  ? and is_show = ?",
       image_start, image_end, device, branch, "daily", "1").select("distinct image_date,branch,battery,vcc_main,power_scenario_id,verified,fps,comments,vcc_main_power").order("image_date asc")
    end

    def get_display_scenarios(scenario_id_list)
        PowerScenario.where("id in (" + scenario_id_list + ")")
    end

    def get_last_latest_power_records(device, branch, image_start, image_end)
        PowerRecord.where("is_show = ? and run_type = ? AND image_date between ? and ? and device = ? and branch = ?", "1", "daily", image_start, get_last_date(image_end), device, branch).order("image_date asc").last
    end

    def get_last_image_date(device,branch, scenario_id_list, image_start, image_end)
        PowerRecord.where("is_show = ? and image_date between ? and ? and run_type = ? and branch = ? and device = ? AND power_scenario_id in (" + scenario_id_list + ")", "1",  image_start, image_end, "daily", branch, device).order("image_date asc").last.image_date
    end

    def get_lcd_infos(device, resolution)
        LcdPower.where("device = ? and resolution = ?", device, resolution)
    end

    def get_lcd_power(device,resolution)
        LcdPower.where("device = ? and resolution = ? and item = ?", device, resolution, "LCD").select("battery").last
    end
    def get_target(scenario_id, device, resolution)
        PowerTarget.where(power_scenario_id: scenario_id, device: device, resolution: resolution).last
    end
    def get_year(image_date)
       	image_date.to_s.split('-')[0]
    end
    def get_month(image_date)
    	image_date.to_s.split('-')[1].to_i - 1
    end

    def get_month_d(image_date)
    	image_date.to_s.split('-')[1].to_i
    end
    def get_day(image_date)
    	image_date.to_s.split('-')[2]
    end
    def get_one_day_before(image_date)
    	image_date.to_s.split('-')[2].to_i - 2
    end

    def get_lcd_backlight(value)
        100 - value
    end

    def get_last_date(image_date)
         date = Date.parse(image_date.to_s)
         Date.parse((date - 1).to_s)
    end

    def get_power(float)
        if float.nil?
         	0
        else
         	index = float.index('.')
            	if index.nil? or float.nil?
                	0
            	else
                	float
            	end
        end
    end
    def get_sub_power(float)
        float = float.to_s
        if !float.nil?
            index = float.index('.')
            if !index.nil? and !float.nil?
                float[0, index + 3]
            end
        end
    end
    def get_sub_name_first(str)
        index = str.index('(')
        str[0, index]
    end
    def get_sub_name_last(str)
        index = str.index('(')
        str[index, str.length]
    end
end
