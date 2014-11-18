class OndemandController < ApplicationController
  def index
  	@tasks = TaskInfo.paginate :page => params[:page], :per_page => 10, :order=>"id desc"
  	@last_task=TaskInfo.last
  end

  def get_task_detail
  	@task_id = params[:task_id]
  	render :layout=>"empty"
  end

  def get_dc
  	@power_record_id = params[:id]
  	@record = PowerRecord.find(:all, :conditions => ['id = ?', @power_record_id]).first
  	render :layout=>"empty"
  end
end
