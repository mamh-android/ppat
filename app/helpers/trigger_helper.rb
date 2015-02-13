module TriggerHelper
	def get_distinct_advanced_category_node(document,platform)
        @hash = Hash.new
        document.elements.each("PPATConfig/PowerAdvanced") { |e|
            if platform == e.elements["Platform"].text then
                category = e.elements["Category"].text
                @categories = @hash[category]
                if @categories.nil?
                    @categories = Set.new
                end
                @categories.add e.elements["CaseName"].text
                @hash[category] = @categories
            end
        }
        @hash
    end
end