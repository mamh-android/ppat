require 'rexml/document'
require 'set'
require 'net/ftp'
require 'net/http'
require 'open-uri'

class TriggerController < ApplicationController
  def index
    conf_f = File.new(Rails.root.to_s + '/app/controllers/ppat_config.xml')
    @tc_conf = REXML::Document::new conf_f
    @power_cases = get_distinct_category_node(@tc_conf, "Power")
    @performance_cases = get_distinct_category_node(@tc_conf, "Performance")

    @devices = get_device_node(@tc_conf)

    file_adv = File.new('/PPAT_test/testcase/config.xml')
    @advanced_conf = REXML::Document::new file_adv
    @cp_cases = get_distinct_advanced_category_node(@advanced_conf, "pxa1928dkb_tz:pxa1928dkb") #use a fake value here
    #job_id = FollowUpEmailJob.create(:length => 100)
    #@status = Resque::Plugins::Status::Hash.get(job_id)
    #job_id = TestJob.create()
    #TestJob.dequeue(TestJob,job_id)
    #job_id = TestJob.create(:device => "pxa1928")
    #job_id = TriggerJenkinsJob.create(:device => "pxa1908")
    #job_id = TestJob.create(:device => "pxa1928")
    #job_id = TriggerEdenJob.create(:platform => "pxa1928", :testcase => "1080p,720p,VGA", :submitter => "zhoulz@marvell.com", :purpose => "just a test")
    #job_id = TriggerHelan3Job.create(:platform => "pxa1936", :testcase => "1080p,720p,VGA", :submitter => "zhoulz@marvell.com", :purpose => "just a test")
    #job_id = TriggerULC1Job.create(:platform => "pxa1908", :testcase => "1080p,720p,VGA", :submitter => "zhoulz@marvell.com", :purpose => "just a test")



    #Resque::Plugins::Status::Hash.remove("53721ac07eb90132f645704da224adaf")
    #@size = Resque::Plugins::Status::Hash.statuses(0,20)


    render :layout=>"ppat"
  end

  def upload
	file = params[:file]
    ftp = Net::FTP.new('10.38.32.98')
    ftp.login(user = "buildfarm", passwd = "123456")
    #ftp.chdir(path_todir) change file save dir
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
    device = params[:device]
    power_cases = get_distinct_category_node(@tc_conf, "Power")
    @power_cases = update_category_node_by_device(@tc_conf,"Power", device, power_cases)
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
end
