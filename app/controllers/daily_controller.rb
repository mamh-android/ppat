class DailyController < ApplicationController
	def index
 		categorys = PowerScenario.where("category not in ('baremetal', 'CMCC', 'DoU', 'sensor','thermal')").select("distinct category")
             @categorys = []
             categorys.each do |cat|
                @categorys << cat
              end
  		@device=params[:device]
  		@branch= params[:branch]

              #basic scenarios for all platform, like video, lpm, ui
              @scenario_id_list ="1001,1002,1003, 2001,2002,2003, 3002,3004,3005,3006, 5001,5003,5004,5005,5006,6001,6002,7001,7002,7003,7004"
              @resolution = "720p"

              #helnlte
              if @device =='pxa1L88dkb'
                  if @branch == 'kk4.4_k310_beta3'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == 'kk4.4_k310_beta2'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == 'kk4.4_k310_beta1'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == "jb4.3_beta1"
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == "kk4.4_master"
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  end
              #heln2
              elsif @device == 'pxa1U88dkb'
                  if @branch == 'kk4.4_master'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  end
              #emei
              elsif @device == 'pxa988dkb'
                  @resolution = "VGA"
                  if @branch == 'jb4.2_beta2'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == 'jb_alpha3'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == 'jb_beta1'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  end
              #heln
              elsif @device == 'pxa1088dkb'
                  @resolution = "VGA"
                  if @branch == 'kk4.4_master'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == 'jb4.3_master'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == 'jb4.2_master'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  end
              #edenff
              elsif @device == 'pxa1928ff'
                  @resolution = "1080p"
                  if @branch == 'kk4.4_master'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == 'lp5.0_master'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == 'lp5.0_alpha1'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  elsif @branch == 'kk4.4_beta2'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003"
                  end
              #eden
              elsif @device=='pxa1928dkb'
                  @resolution = "1080p"
                  if @branch == 'kk4.4_master'
                      @scenario_id_list =@scenario_id_list + ",4010,4011,4012,4013,4014,4015,8001, 8002,10001"
                  elsif @branch == 'lp5.0_master'
                      @scenario_id_list = @scenario_id_list + ",4025, 4026, 4024,4023, 4035,4008, 4009,4027,8001, 8002"
                  elsif @branch == 'lp5.0_alpha1'
                      @scenario_id_list = @scenario_id_list + ",4025, 4026, 4024,4023, 4035,4008, 4009,4027,8001, 8002"

                  elsif @branch == 'kk4.4_beta2'
                      @scenario_id_list = @scenario_id_list + ",4025, 4026, 4024,4023, 4035,4008, 4009,4027,8001, 8002,10001"
                  elsif @branch == 'kk4.4_beta1'
                      @scenario_id_list =@scenario_id_list + ",4010,4011,4012,4013,4014,4015,8001, 8002,10001"
                  elsif @branch == 'kk4.4_alpha2'
                      @scenario_id_list =@scenario_id_list + ",4010,4011,4012,4013,4014,4015,8001, 8002,10001"
                  end
              #ulc1
              elsif @device=='pxa1908dkb'
                  if @branch == 'kk4.4_master'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003, 4019,4020,4021,4022, 8001"
                  elsif @branch == 'lp5.0_master'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003, 4019,4020,4021,4022, 8001"
                  elsif @branch == 'kk4.4_k314_alpha1'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003, 4019,4020,4021,4022, 8001"
                  elsif @branch == 'kk4.4_k314_alpha2'
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003, 4019,4020,4021,4022, 8001"
                  elsif @branch == 'kk4.4_beta1'
                      @resolution = "VGA"
                      @scenario_id_list ="1001,1002,1003, 2001,2002,2003, 4019,4020,4021,4022, 8001"
                  end
              #heln3
              elsif @device=='pxa1936dkb'
                  if @branch == 'lp5.0_master'
                      @scenario_id_list = @scenario_id_list + ",4025, 4026, 4024,4023, 4035,4008, 4009,4027,8001"
                  elsif @branch == 'lp5.0_k314_alpha1'
                      @scenario_id_list = @scenario_id_list + ",4025, 4026, 4024,4023, 4035,4008, 4009,4027,8001"
                  elsif @branch == 'lp5.0_k314_alpha2'
                      @scenario_id_list = @scenario_id_list + ",4025, 4026, 4024,4023, 4035,4008, 4009,4027,8001"
                  elsif @branch == 'lp5.0_k314_beta1'
                      @scenario_id_list = @scenario_id_list + ",4025, 4026, 4024,4023, 4035,4008, 4009,4027,8001"
                  end
              end
  		@os = PowerRecord.where(:device => @device, :branch => @branch).last

              	@images = PowerRecord.where("device = ? AND branch = ? and run_type =  ?", @device, @branch, "daily").select("distinct image_date").order("image_date desc").limit(15)
		image_dates = PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ? and run_type =  ?",
		                    @images.last.image_date, @images.first.image_date, @device, @branch, "daily").select("distinct image_date,battery,vcc_main,power_scenario_id,varified,fps,comments,vcc_main_power").order("image_date asc")
		@image_dates = []
            image_dates.each do |img|
                @image_dates << img
            end
            @last_image= PowerRecord.where("run_type = ? and branch = ? and device = ? AND power_scenario_id in (" + @scenario_id_list + ")", "daily", @branch, @device).order("image_date asc").last.image_date
		scenarios = PowerScenario.where("id in (" + @scenario_id_list + ")")
            @scenarios = []
              scenarios.each do |scenario|
                @scenarios << scenario
              end
		@latest_image_last = PowerRecord.where("run_type = ? AND image_date between ? and ? and device = ? and branch = ? and power_scenario_id in (" + @scenario_id_list + ")", "daily", @images.last.image_date, get_last_date(@last_image), @device, @branch).order("image_date asc").last
		@lcd = LcdPower.where("device = ? and resolution = ? and item = ?", @device, @resolution, "LCD").select("battery").last
		@latest_image=@latest_image_last.image_date
  		render :layout=>"ppat"
  	end
	def query
              @scenario_id_list =params[:scenario_id_list]
              image_date = params[:image_date]
              record_num = params[:record_num].to_i
              @device = params[:device]
              @branch = params[:branch]
              @categorys = PowerScenario.where("category not in ('baremetal', 'CMCC', 'DoU', 'sensor','thermal')").select("distinct category")
              @os = PowerRecord.where(:device => @device, :branch => @branch).last
              record_num_after = record_num / 2
              record_after = PowerRecord.where("image_date >= ? and device = ? and branch = ?", image_date, @device, @branch).select("distinct image_date").order("image_date asc").limit(record_num_after)
              if record_after.last.nil?
                image_date_after = image_date
              else
                image_date_after = record_after.last.image_date
              end
              record_before = PowerRecord.where("image_date < ? and device = ? and branch = ?", image_date, @device, @branch).select("distinct image_date").order("image_date desc").limit(record_num - record_after.size)
              image_date_before = record_before.last.image_date

              @image_dates = PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ?",
                        image_date_before, image_date_after, @device, @branch).select("distinct image_date,battery,vcc_main,power_scenario_id,varified,fps,comments,vcc_main_power").order("image_date asc")

              @last_image= PowerRecord.where("branch = ? and device = ? AND power_scenario_id in (" + @scenario_id_list + ")", @branch, @device).order("image_date asc").last.image_date
              @scenarios = PowerScenario.where("id in (" + @scenario_id_list + ")")
              @latest_image_last = PowerRecord.where("image_date between ? and ? and device = ? and branch = ? and power_scenario_id in (" + @scenario_id_list + ")", image_date_before, get_last_date(image_date_after), @device, @branch).order("image_date asc").last
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

        def  show_chart_by_tab
              @scenario_id_list =params[:scenario_id_list]
              @device=params[:device]
              @branch= params[:branch]
              @os = PowerRecord.where(:device => @device, :branch => @branch).last
              @category = params[:category]

                @images = PowerRecord.where("device = ? AND branch = ? and run_type =  ?", @device, @branch, "daily").select("distinct image_date").order("image_date desc").limit(15)
              @image_dates = PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ? and run_type =  ?",
                        @images.last.image_date, @images.first.image_date, @device, @branch, "daily").select("distinct image_date,battery,vcc_main,power_scenario_id,varified,fps,comments,vcc_main_power").order("image_date asc")
              @last_image= PowerRecord.where("run_type = ? and branch = ? and device = ? AND power_scenario_id in (" + @scenario_id_list + ")", "daily", @branch, @device).order("image_date asc").last.image_date
              @scenarios = PowerScenario.where("id in (" + @scenario_id_list + ")")
              @latest_image_last = PowerRecord.where("run_type = ? AND image_date between ? and ? and device = ? and branch = ? and power_scenario_id in (" + @scenario_id_list + ")", "daily", 11.weeks.ago, get_last_date(@last_image), @device, @branch).order("image_date asc").last
              @lcd = LcdPower.where("device = ? and resolution = ? and item = ?", @device, @resolution, "LCD").select("battery").last
              @latest_image=@latest_image_last.image_date
              respond_to do |format|
                  format.js
              end
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
