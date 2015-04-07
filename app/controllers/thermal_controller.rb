class ThermalController < ApplicationController
	def index
		@thermal_scenarios = ThermalScenario.all
		@device = "pxa1936ff_tz"
		@branch = "lp5.1_master"
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

	def get_comment
		image_date = params[:image_date]
      		temp = params[:temp]
      		@record = ThermalRecord.where(:image_date => image_date, :max_temp=> temp).last
     		 render :layout=>"empty"
	end

	def get_verify
		image_date = params[:image_date]
      		temp = params[:temp]
      		@record = ThermalRecord.where(:image_date => image_date, :max_temp=> temp).last
      		render :layout=>"empty"
	end

	def update_comments
		@image_date = params[:imagedate]
              	@temp = params[:temp]
              	@device = params[:device]
              	@branch = params[:branch]
              	@scenario = params[:casename]

              	@case = ThermalRecord.joins(:thermal_scenario).where(thermal_scenarios: {name: @scenario}, image_date: @image_date, max_temp: @temp).last

              	if params[:verified] != ""
                  		@case.verified=params[:verified]
              	end

              	if params[:comments] != ""
                  		@case.comments=params[:comments]
              	end
              	@case.save
	end
end