require 'rexml/document'
require 'set'
class TriggerController < ApplicationController
  def index
    conf_f = File.new(Rails.root.to_s + '/app/controllers/ppat_config.xml')
    @tc_conf = REXML::Document::new conf_f
    @power_cases = get_distinct_category_node(@tc_conf, "Power")
    @performance_cases = get_distinct_category_node(@tc_conf, "Performance")
    @devices = get_device_node(@tc_conf)

    render :layout=>"ppat"
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
