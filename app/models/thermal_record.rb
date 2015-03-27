class ThermalRecord < ActiveRecord::Base
	belongs_to :thermal_scenario
	has_many :thermal_freq_infos
	has_many :temp_info
end
