require 'set'
require 'net/ftp'
require 'net/http'
require 'open-uri'

class HomeController < ApplicationController
  def index
    @home = CommentRecord.new
    @uploadfile = CommentRecord.new
    unless request.get?
     i=params[:file].size
     @url
     @filesize = 0
     @filesbox= params[:upoadfile_date]
      @filesbox1 = params[:uploadfile_platform]
      @filesbox2 = params[:uploadfile_branch]
      @filesbox3 = params[:uploadfile_device]
      @filesbox4 = params[:uploadfile_username]
     for num in (0..i-1)
      if  @filename=uploadFile(params[:file][num])
     end
     end
   end
  end

  def upload
    @image_date = params[:image_date]
    @username = params[:username]
    @platform = params[:platform]
    @branch = params[:branch]
    @device = params[:device]
    render :layout=>"empty"
  end
  def uploadFile(file)
     if !file.original_filename.empty?
      @filename=getFileName(file.original_filename.gsub(/\s+/,''))
      ftp = Net::FTP.new('10.38.32.98')
      ftp.login(user = "anonymous", passwd = "")
      ftp.chdir("comments")
      begin
        ftp.mkdir(@filesbox+"-"+@filesbox1+"-"+@filesbox2+"-"+@filesbox3+"-"+@filesbox4)
      rescue Net::FTPPermError
      end
      ftp.chdir(@filesbox+"-"+@filesbox1+"-"+@filesbox2+"-"+@filesbox3+"-"+@filesbox4)
      ftp.passive = true
      ftp.storbinary("STOR " + @filename, StringIO.new(file.read), Net::FTP::DEFAULT_BLOCKSIZE)
      ftp.quit()
    return @filename
    end
  end

  def getFileName(filename)
     if !filename.nil?
        return filename
     end
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

  def comments
    @image_date = params[:image_date]
    @platform = params[:platform]
    @branch = params[:branch]
    @device = params[:device]
    @comment_records_list = CommentRecord.where(uploadtime: @image_date).order("created_at desc")
    render :layout=>"empty"
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
    @scenarios = PowerRecord.where(['platform = ? and image_date = ? and branch = ? and device = ? and run_type = ? ', @platform, @image_date, @branch,@device, "daily"])
    render :layout=>"empty"
  end
  # GET /comment_records/new
  def new
    @home = CommentRecord.new
  end
end
