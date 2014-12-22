class HomeController < ApplicationController
  def index
    @tasks = PowerRecord.paginate :page => params[:page], :per_page => 10, :order=>"id desc"
    @last_task=PowerRecord.last
    @cart = get_cart
  end

  def get_platform_detail
    @image_date = params[:image_date]
    @platform = params[:platform]
    @branch = params[:branch]
    @scenarios = PowerRecord.find(:all, :conditions => ['platform = ? and image_date = ? and branch = ?', @platform, @image_date, @branch])
    render :layout=>"empty"
  end
end
