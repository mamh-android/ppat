class CompareController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def index
        @cart = get_cart
        @platformes = ["hln3", "hln3ff","ulc1","ulc1ff","eden","edenff"]
        @devices = PowerRecord.where(platform: @platformes[0], run_type: "daily").select("distinct device")
        devices = []
        @devices.each do |device|
            devices << device.device
        end
        @branches = PowerRecord.where(platform: @platformes[0], device: devices[0], run_type: "daily").select("distinct branch")
        branches = []
        @branches.each do |branch|
            branches << branch.branch
        end
        @datesEnable = PowerRecord.where(branch: branches[0], device: devices[0], run_type: "daily").select("distinct image_date")
        render :layout=>"ppat"
    end

    def add_daily_compare
        image_date = params[:ImageDate]
        branch = params[:Branch]
        device = params[:Device]
        platform = params[:Platform]
        @cart = get_cart
        @scenarios = PowerRecord.where('image_date = ? and branch = ? and device = ? and platform = ? and run_type=?', image_date,branch, device, platform, "daily").group("power_scenario_id")
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

    def get_device
        platform = params[:platform]
        #get all  devices
        @devices = PowerRecord.where(platform: platform, run_type: "daily").select("distinct device")
        devices = []
        @devices.each do |device|
            devices << device.device
        end
        @branches = PowerRecord.where(platform: platform, device: devices[0], run_type: "daily").select("distinct branch")
        branches = []
        @branches.each do |branch|
            branches << branch.branch
        end
        @datesEnable = PowerRecord.where(branch: branches[0], device: devices[0], run_type: "daily").select("distinct image_date")
        respond_to do |format|
            format.js
        end
    end

    def get_branch
        platform = params[:platform]
        device = params[:device]

        #get all branches
        @branches = PowerRecord.where(platform: platform, device: device, run_type: "daily").select("distinct branch")
        branches = []
        @branches.each do |branch|
            branches << branch.branch
        end
        @datesEnable = PowerRecord.where(branch: branches[0], device: device, run_type: "daily").select("distinct image_date")
        respond_to do |format|
            format.js
        end
    end

    def update_datepicker
        device = params[:device]
        branch = params[:branch]
        @datesEnable = PowerRecord.where(branch: branch, device: device, run_type: "daily").select("distinct image_date")
        respond_to do |format|
            format.js
        end
    end
end
