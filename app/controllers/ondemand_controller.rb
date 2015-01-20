class OndemandController < ApplicationController
    def index
        @tasks = TaskInfo.all
        @cart = get_cart
        render :layout=>"ppat"
    end

    def get_task_detail
    	@task_id = params[:task_id]
    	render :layout=>"empty"
    end

    def get_dc
    	@power_record_id = params[:id]
        @record = PowerRecord.where(:id, @power_record_id).first
    	#@record = PowerRecord.find(:all, :conditions => ['id = ?', @power_record_id]).first
    	render :layout=>"empty"
    end
end
