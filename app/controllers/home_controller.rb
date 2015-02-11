class HomeController < ApplicationController
  def index
  end

  def update_calendar
    @platform = params[:platform]
    @branch = params[:branch]
    @device = params[:device]
    @show_smoketest = params[:show_smoketest]
    respond_to do |format|
        format.js
    end
  end

  def get_code_drop
    @platform = params[:platform]
    @scenariocode = PlatformBranch.where(['platform = ?', @platform])
    respond_to do |format|
      puts format
        format.js
    end
  end

  def get_platform_detail
    @image_date = params[:image_date]
    @platform = params[:platform]
    @branch = params[:branch]
    @device = params[:device]
    @scenarios = PowerRecord.where(['platform = ? and image_date = ? and branch = ? and device = ?', @platform, @image_date, @branch,@device])
    render :layout=>"empty"
  end
end
