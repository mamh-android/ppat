require 'set'
module CompareHelper
    #get distinct purpose
    def get_distinct_purposes()
        @cart = get_cart
        @purposes = []
        @cart.record_list.each do |record|
            record_info = get_record_info(record.power_record.id)
            if record_info.device.nil?
                record_info.device = ""
            end
            if record_info.image_date.nil?
                record_info.image_date=""
            end
            @purposes << record_info.purpose + "-" + record_info.device + "-" + record_info.image_date
        end
        @purposes.uniq
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
        PowerScenario.where(id: scenario_id).last.category
        #PowerScenario.find(:all, :conditions => ['id = ?', scenario_id]).last.category
    end

    def get_scenario_category_all()
        PowerScenario.order("category desc")
        #PowerScenario.find(:all, :conditions => ['id = ?', scenario_id]).last.category
    end

    def get_scenario_id_into(name)
        PowerScenario.where(name: name).select("distinct id")
    end

    class Array
        def count(val)
            cnt = 0
            self.each{|x|
                if x == val
                    cnt+=1
                end
            }
                cnt
            end
        end
end
