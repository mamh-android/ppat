class MemoryController < ApplicationController
    @@start = ""
    @@end = ""
    @@category = "" #memory 的分类

    def index
        @categorys = []
        categorys = MemoryScenario.where("is_show = 1").select("distinct category")
        categorys.each do |category|
            @categorys << category.category
        end
        @categorys << "All"
        @category = @categorys[0]
        @@category = @category

        @device=params[:device]
        @branch= params[:branch]
        @platform=params[:platform]
        @ddrsize=params[:ddrsize]

        image_dates = MemoryRecord.where("platform=? and branch=? and device=? and ddr_size=? and is_show=1",
                                         @platform, @branch, @device, @ddrsize).select("distinct image_date").order("image_date desc").limit(15)
        @start = image_dates.last.image_date
        @end = image_dates.first.image_date

        @@start = @start
        @@end = @end

        @datesEnable = MemoryRecord.where(platform:@platform, branch: @branch, device: @device, ddr_size:@ddrsize, is_show:1).select("distinct image_date")
        render :layout=>"ppat"
    end

    def query
        @scenario_id_list =params[:scenario_id_list]
        image_date = params[:image_date]
        record_num = params[:record_num].to_i
        @device = params[:device]
        @branch = params[:branch]
        @platform=params[:platform]
        @ddrsize=params[:ddrsize]
        @last_image = image_date
        @category = @@category
        record_num_after = record_num / 2
        record_after = MemoryRecord.where("platform=? and branch=? and device=? and ddr_size=? and is_show=1",
                                        @platform, @branch, @device, @ddrsize).select("distinct image_date").order("image_date asc").limit(record_num_after)
        if record_after.last.nil?
            @@end = image_date
        else
            @@end = record_after.last.image_date
        end
        record_before = MemoryRecord.where("platform=? and branch=? and device=? and ddr_size=? and is_show=1",
                                          @platform, @branch, @device, @ddrsize).select("distinct image_date").order("image_date desc").limit(record_num - record_after.size)
        @@start = record_before.last.image_date

        @start = @@start
        @end =  @@end
        respond_to do |format|
            format.js
        end
    end

    def get_comment
        image_date = params[:image_date]
        memory = params[:memory]
        @record = MemoryRecord.where(:image_date => image_date, :memory => memory).last
        render :layout=>"empty"
    end

    def  show_chart_by_tab
        @device = params[:device]
        @branch = params[:branch]
        @platform = params[:platform]
        @ddrsize = params[:ddrsize]
        @@category = params[:category]

        @category = @@category
        @start = @@start
        @end =  @@end
        respond_to do |format|
            format.js
        end
    end

    def update_comments
        @image_date = params[:imagedate]
        @memory = params[:memory]
        @device = params[:device]
        @branch = params[:branch]
        @platform=params[:platform]
        @ddrsize=params[:ddrsize]

        @scenario = MemoryScenario.where(name: params[:casename])
        @case = MemoryRecord.where(memory_scenario_id: @scenario, image_date: @image_date, memory: @memory).last

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
        memory = params[:memory]
        @record = MemoryRecord.where(:image_date => image_date, :memory=> memory).last
        render :layout=>"empty"
    end

    def show_dc
        image_date = params[:image_date]
        memory = params[:memory]
        scenario_name = params[:scenario]
        scenario_id = MemoryScenario.where(name: scenario_name).first.id
        @record = MemoryRecord.where(:memory_scenario_id => scenario_id, :image_date => image_date, :memory => memory).first
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
