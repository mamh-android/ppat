class DailyController < ApplicationController
	def index
 		@categorys = PowerScenario.select("distinct category")
  		@device=params[:device]
  		@branch= params[:branch]
  		@os = PowerRecord.where(:device => @device, :branch => @branch).last

		@image_dates = PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ?",
		                    11.weeks.ago, Time.now, @device, @branch).select("distinct image_date,battery,vcc_main,power_scenario_id,varified,fps,comments,vcc_main_power").order("image_date asc")
		@last_image= PowerRecord.where("branch = ? and device = ? AND power_scenario_id in (1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,19,21,22,23,24,25,26,27,33,34,35,36,18)", @branch, @device).order("image_date asc").last.image_date
		@scenarios = PowerScenario.where("id in (1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,19,21,22,23,24,25,26,27,33,34,35,36,18)")
		@latest_image_last = PowerRecord.where("image_date between ? and ? and device = ? and branch = ? and power_scenario_id in (1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,19,21,22,23,24,25,26,27,33,34,35,36,18)", 11.weeks.ago, get_last_date(@last_image), @device, @branch).order("image_date asc").last
		@lcd = LcdPower.where("device = ? and resolution = ? and item = ?", "pxa1L88dkb", "720p", "LCD").select("battery").last
		@latest_image=@latest_image_last.image_date
  		render :layout=>"ppat"
  	end
	def query
              image_date = params[:image_date]
              record_num = params[:record_num].to_i
              @device = params[:device]
              @branch = params[:branch]
              @categorys = PowerScenario.select("distinct category")
              @os = PowerRecord.where(:device => @device, :branch => @branch).last
              record_num_after = record_num / 2
              record_after = PowerRecord.where("image_date >= ? and device = ? and branch = ?", image_date, @device, @branch).select("distinct image_date").order("image_date asc").limit(record_num_after)
              image_date_after = record_after.last.image_date
              record_before = PowerRecord.where("image_date < ? and device = ? and branch = ?", image_date, @device, @branch).select("distinct image_date").order("image_date desc").limit(record_num - record_after.size)
              image_date_before = record_before.last.image_date

              @image_dates = PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ?",
                        image_date_before, image_date_after, @device, @branch).select("distinct image_date,battery,vcc_main,power_scenario_id,varified,fps,comments,vcc_main_power").order("image_date asc")

              @last_image= PowerRecord.where("branch = ? and device = ? AND power_scenario_id in (1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,19,21,22,23,24,25,26,27,33,34,35,36,18)", @branch, @device).order("image_date asc").last.image_date
              @scenarios = PowerScenario.where("id in (1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,19,21,22,23,24,25,26,27,33,34,35,36,18)")
              @latest_image_last = PowerRecord.where("image_date between ? and ? and device = ? and branch = ? and power_scenario_id in (1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,19,21,22,23,24,25,26,27,33,34,35,36,18)", image_date_before, get_last_date(image_date_after), @device, @branch).order("image_date asc").last
              @lcd = LcdPower.where("device = ? and resolution = ? and item = ?", "pxa1L88dkb", "720p", "LCD").select("battery").last
              @latest_image=@latest_image_last.image_date
              respond_to do |format|
                  format.js
              end
  	end

  	def get_comment
  		image_date = params[:image_date]
  		battery = params[:battery]
  		@record = PowerRecord.where(:image_date => image_date, :battery=> battery).last
  		render :layout=>"empty"
  	end

      def update_comments
              @image_date = params[:imagedate]
              @power = params[:power]
              @device = params[:device]
              @branch = params[:branch]

              @scenario = PowerScenario.where(name: params[:casename])
              @case = PowerRecord.where(power_scenario_id: @scenario, image_date: @image_date, battery: @power).last

              if params[:varified] != ""
                  @case.varified=params[:varified]
              end

              if params[:comments] != ""
                  @case.comments=params[:comments]
              end
              @case.save
      end
  	def get_verify
  		image_date = params[:image_date]
  		battery = params[:battery]
  		@record = PowerRecord.where(:image_date => image_date, :battery=> battery).last
  		render :layout=>"empty"
  	end

  	def show_dc
  		image_date = params[:image_date]
  		battery = params[:battery]
  		scenario_name = params[:scenario]
  		scenario_id = PowerScenario.where(name: scenario_name).first.id
        		@record = PowerRecord.where(:power_scenario_id => scenario_id, :image_date => image_date, :battery => battery ).first
    		render :layout=>"empty"
    	end
private
    	#get 30 days before given image_date
    	def get_last30_date(image_date)
        		date = Date.parse(image_date.to_s)
        		Date.parse((date - 30).to_s)
    	end

    	#get the day before given image_date
    	def get_last_date(image_date)
        		date = Date.parse(image_date.to_s)
        		Date.parse((date - 1).to_s)
    	end
end
