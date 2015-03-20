class CompareController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def index
        @cart = get_cart
        render :layout=>"ppat"
    end

    def add_daily_compare
        image_date = params[:ImageDate]
        branch = params[:Branch]
        device = params[:Device]
        platform = params[:Platform]
        @task_id = PowerRecord.where('image_date = ? and branch = ? and device = ? and platform = ? and run_type=?', image_date,branch, device, platform, "daily").first.task_id
        @cart = get_cart
        @scenarios = PowerRecord.where('task_id = ?', @task_id).group("power_scenario_id")
        @scenarios.each do |power_record|
            @record_list = @cart.record_list.build(:power_record => power_record)
            @record_list.save
        end
        respond_to do |format|
            format.js
        end
    end

    def get_dc_by_battery
        battery = params[:battery]
        @record = PowerRecord.where(battery: battery).first
        @power_record_id = @record.id
        #@record = PowerRecord.find(:all, :conditions => ['id = ?', @power_record_id]).first
        render :layout=>"empty"
    end


      def create_by_task
        @cart = get_cart
        @scenarios = PowerRecord.where(task_id:  params[:task_id])
        @scenarios.each do |power_record|
          @record_list = @cart.record_list.build(:power_record => power_record)
          @record_list.save
        end
        respond_to do |format|
            format.js
        end
      end

      def create_by_scenario
        @cart = get_cart
        power_record = PowerRecord.find(params[:power_record_id])
        @record_list = @cart.record_list.build(:power_record => power_record)
        @record_list.save
        respond_to do |format|
          format.js
        end
    end

    def remove_by_taskid
        @cart = get_cart
        @cart.record_list.each do |record|
            if PowerRecord.find(record.power_record_id).task_id == params[:task_id]
                record.destroy
            end
        end
        respond_to do |format|
            format.js
        end
    end
    def get_dc
            @battery = params[:battery]
                @record = PowerRecord.where(battery: @battery).first
            render :layout=>"empty"
    end
end
