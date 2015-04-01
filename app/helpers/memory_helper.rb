module MemoryHelper
    def get_daily_memory(image_date, scenario_id, device, branch, platform, ddrsize)
        MemoryRecord.where('image_date = ? and memory_scenario_id = ? and device = ? and branch = ? and platform = ? and is_show = ? and ddr_size = ?',
                           image_date, scenario_id, device, branch, platform, "1", ddrsize)
    end
    def get_last_memory(image_date, scenario_id, device, branch, platform, ddrsize)
        MemoryRecord.where('image_date = ? and memory_scenario_id = ? and device = ? and branch = ? and platform = ? and is_show = ? and ddr_size = ?',
                           image_date, scenario_id, device, branch, platform, "1", ddrsize).last
    end

    def get_memory_display_image_dates(device, branch, platform, ddrsize)
        MemoryRecord.where("device = ? AND branch = ? and platform = ? and is_show = ? and ddr_size = ?",
                           device, branch, platform, "1", ddrsize).select("distinct image_date").order("image_date desc").limit(15)
    end

    def get_memory_display_scenarios_id(device, branch, platform, image_start, image_end, ddrsize)
        MemoryRecord.where("branch = ? and device = ? and platform = ? and is_show = 1 and ddr_size = ? and image_date BETWEEN ? AND ? ",
                           branch, device, platform, ddrsize, image_start, image_end).select("group_concat(distinct memory_scenario_id) as list").last.list
    end

    def get_memory_display_records(device, branch, platform, image_start, image_end, ddrsize)
        MemoryRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ? and platform = ? and is_show = ? and ddr_size = ?",
                           image_start, image_end, device, branch, platform, "1", ddrsize).
                           select("distinct memory_scenario_id, image_date,platform,branch,device,memory,unit,comments,link,verified").
                           order("image_date asc")
    end

    def get_memory_display_scenarios(scenario_id_list)
        MemoryScenario.where("id in (" + scenario_id_list + ")")
    end

    def get_last_latest_memory_records(device, branch, platform, image_start, image_end, ddrsize)
        MemoryRecord.where("is_show = ? and image_date between ? and ? and device = ? and branch = ? and platform = ? and ddr_size = ?",
                           "1", image_start, get_last_date(image_end), device, branch, platform, ddrsize).order("image_date asc").last
    end

    def get_memory_last_image_date(device, branch, platform, scenario_id_list, image_start, image_end, ddrsize)
        MemoryRecord.where("is_show = ? and image_date between ? and ? and platform = ? and branch = ? and device = ? AND memory_scenario_id in (" +
                           scenario_id_list + ")", "1",  image_start, image_end, platform, branch, device).order("image_date asc").last.image_date
    end
    def get_memory_last_link(device, branch, platform, scenario_id_list, image_start, image_end, ddrsize)
        MemoryRecord.where("is_show = ? and image_date between ? and ? and platform = ? and branch = ? and device = ? AND memory_scenario_id in (" +
                           scenario_id_list + ")", "1",  image_start, image_end, platform, branch, device).order("image_date asc").last.link
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

    def get_memory(float)
        float
    end
    def get_sub_memory(float)
        float
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
