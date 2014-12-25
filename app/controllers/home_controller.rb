class HomeController < ApplicationController
  def update_calendar
    @platform = params[:platform]
    @branch = params[:branch]
    @device = params[:device]
    respond_to do |format|
        format.js
    end
  end

  def get_platform_detail
    @image_date = params[:image_date]
    @platform = params[:platform]
    @branch = params[:branch]
    @device = params[:device]
    @scenarios = PowerRecord.find(:all, :conditions => ['platform = ? and image_date = ? and branch = ? and device = ?', @platform, @image_date, @branch,@device])
    render :layout=>"empty"
  end
end
