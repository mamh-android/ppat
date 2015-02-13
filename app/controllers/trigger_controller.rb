require 'rexml/document'
require 'set'
require 'net/ftp'
require 'net/http'
require 'open-uri'
require 'jenkins_api_client'

class TriggerController < ApplicationController
  def index
    @now = get_now
    conf_f = File.new(Rails.root.to_s + '/app/controllers/ppat_config.xml')
    @tc_conf = REXML::Document::new conf_f
    @power_cases = get_distinct_category_node(@tc_conf, "Power")
    @performance_cases = get_distinct_category_node(@tc_conf, "Performance")

    @devices = get_device_node(@tc_conf)
    file_adv = File.new('/PPAT_test/testcase/config.xml')
    @advanced_conf = REXML::Document::new file_adv
    @cp_cases = get_distinct_advanced_category_node(@advanced_conf, "pxa1908dkb_tz:pxa1908dkb")

    render :layout=>"ppat"
  end

  def trigger
    device = params[:device]
    blf = params[:blf]
    image_path = params[:image_path]
    hw = params[:hw]
    testcase = params[:testcase]

    if device == "pxa1908dkb_tz:pxa1908dkb"
        TriggerULC1Job.create({:platform => "ulc1", :device => device, :blf => blf, :image_path => image_path, :hw => hw, :testcase => testcase})
    elsif device == "pxa1928dkb_tz:pxa1928dkb"
        TriggerEdenJob.create({:platform => "eden", :device => device, :blf => blf, :image_path => image_path, :hw => hw, :testcase => testcase})
    elsif device == "pxa1936dkb_tz:pxa1936dkb"
        TriggerHelan3Job.create({:platform => "helan3", :device => device, :blf => blf, :image_path => image_path, :hw => hw, :testcase => testcase})
    end
    redirect_to "/query/index"
  end

  def update_testcase
    device = params[:device]
    @testtype = params[:type]
    hwmodule = params[:module]
    conf_f = File.new(Rails.root.to_s + '/app/controllers/ppat_config.xml')
    @tc_conf = REXML::Document::new conf_f
    @devices = get_device_node(@tc_conf)
    @device_with_module = get_hw_module(@tc_conf)[device]

    ubt_f = File.new(Rails.root.to_s + '/app/controllers/uboot_config.xml')
    @uboot_conf = REXML::Document::new ubt_f

    file_adv = File.new('/PPAT_test/testcase/config.xml')
    @advanced_conf = REXML::Document::new file_adv

    if @testtype == "Round PP Tuning"
        basic_power_cases = get_distinct_category_node(@tc_conf, "Power")
        @power_cases = update_category_node_by_device(@tc_conf,"Power", hwmodule, basic_power_cases)
        @performance_cases = get_distinct_category_node(@tc_conf, "Performance")
    	@pp_infos = get_device_components_pp(@tc_conf, device)
    elsif @testtype == "Baremetal Power"
    	@bare_infos = get_device_uboot_tcs(@uboot_conf, device)
    else
        basic_power_cases = get_distinct_category_node(@tc_conf, "Power")
        @power_cases = update_category_node_by_device(@tc_conf,"Power", hwmodule, basic_power_cases)
        @performance_cases = get_distinct_category_node(@tc_conf, "Performance")
    	@cp_cases = get_distinct_advanced_category_node(@advanced_conf, device)
    end
	respond_to do |format|
        format.js
    end
  end

  def upload
    file = params[:file]
    directory = params[:dir]
    ftp = Net::FTP.new('10.38.32.98')
    ftp.login(user = "buildfarm", passwd = "123456")
    begin
        ftp.mkdir(directory)
    rescue Net::FTPPermError
        #ftp.chdir(directory) #change file save dir
    end
    ftp.chdir(directory)
    ftp.passive = true
    #ftp.putbinaryfile(file.read, File.basename(file.original_filename))
    ftp.storbinary("STOR " + file.original_filename, StringIO.new(file.read), Net::FTP::DEFAULT_BLOCKSIZE)
    #ftp.getbinaryfile(file.original_filename, file.original_filename, 1024) get file
    ftp.quit()
  end

  def get_device
    conf_f = File.new(Rails.root.to_s + '/app/controllers/ppat_config.xml')
    @tc_conf = REXML::Document::new conf_f
    @devices = get_device_node(@tc_conf)
    device = params[:module]
    power_cases = get_distinct_category_node(@tc_conf, "Power")
    @power_cases = update_category_node_by_device(@tc_conf,"Power", device, power_cases)
    @blf_arr = update_blf_by_device(@tc_conf, device)
    respond_to do |format|
        format.js
    end
  end
 private
    def get_distinct_category_node(document,type)
        @hash = Hash.new
        document.elements.each("PPATConfig/" + type) { |e|
            category = e.elements["Category"].text
            @categories = @hash[category]
            if @categories.nil?
                @categories = Set.new
            end
            @categories.add e.elements["CaseName"].text
            @hash[category] = @categories
        }
        @hash
    end


    def get_distinct_advanced_category_node(document,platform)
        @hash = Hash.new
        document.elements.each("PPATConfig/PowerAdvanced") { |e|
            if platform == e.elements["Platform"].text then
                category = e.elements["Category"].text
                @categories = @hash[category]
                if @categories.nil?
                    @categories = Set.new
                end
                @categories.add e.elements["CaseName"].text
                @hash[category] = @categories
            end
        }
        @hash
    end

    def get_device_node(document)
        @hash = Hash.new
        document.elements.each("PPATConfig/Device") { |e|
            name = e.elements["Name"].text
            @cases = @hash[name]
            if @cases.nil?
                @cases = Set.new
            end
            e.elements.each("TestCase") { |tc|
                testcase = tc.elements["CaseName"].text#e.attributes["name"]
                @cases.add testcase
            }
            @hash[name] = @cases
        }
        @hash
    end

    def get_hw_module(document)
        @hash = Hash.new
        document.elements.each("PPATConfig/Board") { |board|
            device = board.elements["Type"].text
            @hw = @hash[device]
            if @hw.nil?
                @hw = Set.new
            end
            board.elements.each("HW/Name") { |name|
                device_name = name.text
                @hw.add device_name
            }
            @hash[device] = @hw
        }
        @hash
    end

    def update_category_node_by_device(document,type,device,hashSet)
        document.elements.each("PPATConfig/Device") { |e|
            if device == e.elements["Name"].text  then
                e.elements.each("TestCase/CaseName") { |tc|
                    category = tc.attributes["Category"]
                    categories = hashSet[category]
                    if categories.nil?
                        categories = Set.new
                    end
                    categories.add tc.text
                    hashSet[category] = categories
                }
            end
        }
        hashSet
    end

    def update_blf_by_device(document, device)
        blf_arr = Array.new
        document.elements.each("PPATConfig/Device") { |e|
            if device == e.elements["Name"].text  then
                e.elements.each("BLF") { |blf|
                    blf_arr.push(blf.text)
                }
            end
        }
        blf_arr
    end

    def get_device_components_pp(document, device)
    	@result = ""
    	document.elements.each("PPATConfig/Tune/Device") { |dev|
    		if device == dev.attributes["name"] then
    			@result = dev
    		end
    	}
    	@result
    end

    def get_device_uboot_tcs(document, device)
    	@result = ""
    	document.elements.each("Uboot/Device") { |dev|
    		if device == dev.attributes["name"] then
    			@result = dev
    		end
    	}
    	@result
    end
end
