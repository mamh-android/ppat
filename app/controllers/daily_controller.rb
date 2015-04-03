class DailyController < ApplicationController
  def index
    @categorys = PowerScenario.where("category not in ('baremetal', 'CMCC', 'DoU', 'sensor','thermal')").select("distinct category")

      @device=params[:device]
      @branch= params[:branch]

      @resolution = "720p"


        @datesEnable = PowerRecord.where(branch: @branch, device: @device, run_type: "daily").select("distinct image_date")
       @images = PowerRecord.where("device = ? AND branch = ? and run_type =  ?", @device, @branch, "daily").select("distinct image_date").order("image_date desc").limit(15)
       @scenario_id_list = PowerRecord.where("branch = ? and device = ? and is_show = 1 and image_date BETWEEN ? AND ? ", @branch, @device, @images.last.image_date, @images.first.image_date).select("group_concat(distinct power_scenario_id) as list").last.list

      @image_dates = PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ? and run_type =  ? and is_show = ?",
       @images.last.image_date, @images.first.image_date, @device, @branch, "daily", "1").select("distinct image_date,branch,battery,vcc_main,power_scenario_id,verified,fps,comments,vcc_main_power").order("image_date asc")

       @last_image= PowerRecord.where("run_type = ? and branch = ? and device = ? AND power_scenario_id in (" + @scenario_id_list + ")", "daily", @branch, @device).order("image_date asc").last.image_date
    @scenarios = PowerScenario.where("id in (" + @scenario_id_list + ")")

    @latest_image_last = PowerRecord.where("run_type = ? AND image_date between ? and ? and device = ? and branch = ? and power_scenario_id in (" + @scenario_id_list + ")", "daily", @images.last.image_date, get_last_date(@last_image), @device, @branch).order("image_date asc").last

      @os = @image_dates.last
      @lcd = LcdPower.where("device = ? and resolution = ? and item = ?", @device, @resolution, "LCD").select("battery").last
              @lcd_infos = LcdPower.where("device = ? and resolution = ?", @device, @resolution)
     if !@latest_image_last.nil?
              @latest_image=@latest_image_last.image_date
            end
      render :layout=>"ppat"
    end
  def query
              @scenario_id_list =params[:scenario_id_list]
              image_date = params[:image_date]
              record_num = params[:record_num].to_i
              @device = params[:device]
              @branch = params[:branch]
              @categorys = PowerScenario.where("category not in ('baremetal', 'CMCC', 'DoU', 'sensor','thermal')").select("distinct category")

              record_num_after = record_num / 2
              record_after = PowerRecord.where("image_date >= ? and device = ? and branch = ?", image_date, @device, @branch).select("distinct image_date").order("image_date asc").limit(record_num_after)
              if record_after.last.nil?
                image_date_after = image_date
              else
                image_date_after = record_after.last.image_date
              end
              record_before = PowerRecord.where("image_date < ? and device = ? and branch = ?", image_date, @device, @branch).select("distinct image_date").order("image_date desc").limit(record_num - record_after.size)
              image_date_before = record_before.last.image_date

              @image_dates = PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ? and is_show = ? and run_type =  ?",
                        image_date_before, image_date_after, @device, @branch, "1", "daily").select("distinct image_date,branch,battery,vcc_main,power_scenario_id,verified,fps,comments,vcc_main_power").order("image_date asc")

              @last_image= PowerRecord.where("branch = ? and device = ? AND power_scenario_id in (" + @scenario_id_list + ")", @branch, @device).order("image_date asc").last.image_date
              @scenarios = PowerScenario.where("id in (" + @scenario_id_list + ")")
              @latest_image_last = PowerRecord.where("image_date between ? and ? and device = ? and branch = ? and power_scenario_id in (" + @scenario_id_list + ")", image_date_before, get_last_date(image_date_after), @device, @branch).order("image_date asc").last
              @os = @image_dates.last
              @lcd = LcdPower.where("device = ? and resolution = ? and item = ?", @device, @resolution, "LCD").select("battery").last
            @lcd_infos = LcdPower.where("device = ? and resolution = ?", @device, @resolution)
            if !@latest_image_last.nil?
              @latest_image=@latest_image_last.image_date
            end
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
              @category = params[:category]

                @images = PowerRecord.where("device = ? AND branch = ? and run_type =  ?", @device, @branch, "daily").select("distinct image_date").order("image_date desc").limit(15)
              @image_dates = PowerRecord.where("image_date BETWEEN ? AND ? AND device = ? AND branch = ? and run_type =  ? and is_show = ?",
                        @images.last.image_date, @images.first.image_date, @device, @branch, "daily", "1").select("distinct image_date,branch,battery,vcc_main,power_scenario_id,verified,fps,comments,vcc_main_power").order("image_date asc")
              @last_image= PowerRecord.where("run_type = ? and branch = ? and device = ? AND power_scenario_id in (" + @scenario_id_list + ")", "daily", @branch, @device).order("image_date asc").last.image_date
              @scenarios = PowerScenario.where("id in (" + @scenario_id_list + ")")
              @latest_image_last = PowerRecord.where("run_type = ? AND image_date between ? and ? and device = ? and branch = ? and power_scenario_id in (" + @scenario_id_list + ")", "daily", 11.weeks.ago, get_last_date(@last_image), @device, @branch).order("image_date asc").last
              @os = @image_dates.last
              @lcd = LcdPower.where("device = ? and resolution = ? and item = ?", @device, @resolution, "LCD").select("battery").last
               if !@latest_image_last.nil?
              @latest_image=@latest_image_last.image_date
            end
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

              if params[:verified] != ""
                  @case.verified=params[:verified]
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
