class ThermalController < ApplicationController
	def index
		@thermal_scenarios = ThermalScenario.all
		@thermal = ThermalRecord.joins(:thermal_scenario).select("thermal_records.*, name")
  		render :layout=>"no_cart"
	end

	def query
		scenario = params[:scenario]
		image_date = params[:image_date]
		temp = params[:temp]
		@thermal_record = ThermalRecord.joins(:thermal_scenario).where("max_temp = ? and image_date = ? and thermal_scenarios.name = ?",
				temp, image_date, scenario).select("thermal_records.*, name").first
		@temp = TempInfo.joins(:thermal_record).where(thermal_record_id: @thermal_record.id)
		@freq = ThermalFreqInfo.joins(:thermal_record).where(thermal_record_id: @thermal_record.id)
  		render :layout=>"empty"
	end
end