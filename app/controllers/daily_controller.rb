class DailyController < ApplicationController
	def index
 		@categorys = PowerScenario.select("distinct category")
  		@device="pxa1908dkb"
  		@branch= "kk4.4_master"
  		@os = PowerRecord.where(:device => @device, :branch => @branch).last

		@image_dates = PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ?",
		                    5.weeks.ago, Time.now, @device, @branch).select("distinct image_date,battery,vcc_main,power_scenario_id,varified,fps,comments,vcc_main_power").order("image_date asc")

		@last_image= PowerRecord.where("branch = ? and device = ? AND power_scenario_id in (1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,19,21,22,23,24,25,26,27,33,34,35,36,18)", @branch, @device).order("image_date asc").last.image_date
		@scenarios = PowerScenario.where("id in (1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,19,21,22,23,24,25,26,27,33,34,35,36,18)")
		@latest_image_last = PowerRecord.where("image_date between ? and ? and device = ? and branch = ? and power_scenario_id in (1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,19,21,22,23,24,25,26,27,33,34,35,36,18)", 4.weeks.ago, @last_image, @device, @branch).order("image_date asc").last
		@lcd = LcdPower.where("device = ? and resolution = ? and item = ?", "pxa1L88dkb", "720p", "LCD").select("battery").last

  		render :layout=>"ppat"
  	end
	def query
  	end
end
