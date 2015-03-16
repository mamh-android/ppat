require 'net/http'
require 'net/ftp'
require 'open-uri'
require 'jenkins_api_client'
class TriggerULC1Job < Resque::JobWithStatus
	include Resque::Plugins::Status
	@queue = :ulc1
	#send url request to jenkins, wait until jenkins job finished
  	def perform
		#build job
		client = JenkinsApi::Client.new(:server_ip => '10.38.120.30', :username => 'ppat', :password => '79fa7f655d56115da6fe7d707f63fd12')
		build_que = JenkinsApi::Client::BuildQueue.new(client)
		job_params = {
		    'IMAGEPATH' => options['image_path'],
		    'BLF' => options['blf'],
		    'PURPOSE' => options['purpose'],
		    'DEVICE' => options['device'],
		    'TESTCASE' => options['testcase'],
		    'ASSIGNER' => options['assigner']
		}
		opts = {}
		#check whether jenkins is running
		job = JenkinsApi::Client::Job.new(client)
		jenkins_job_name = "PPAT_ULC1"
		hw = options['hw'].to_s
		if hw == 'ULC1_1: Daily use'
			jenkins_job_name = "PPAT_ULC1"
		elsif hw == 'ULC1_2: Camera OV13850'
			jenkins_job_name = "PPAT_ULC1_1"
		elsif hw == 'HW Module1:Camera OV5647'
			jenkins_job_name = "PPAT_ULC1_FF"
		end
		jenkins_status = job.get_current_build_status(jenkins_job_name) # running, success, failure
		while jenkins_status == "running" do
			jenkins_status = job.get_current_build_status(jenkins_job_name)
			sleep(10)
		end
		# trigger jenkins job
		response_code = client.job.build(jenkins_job_name, job_params || {}, opts)
		sleep(35)
		if response_code == 201
			#
		end
		buildNum = job.get_current_build_number(jenkins_job_name).to_s
		set_status('log' => "http://10.38.120.30:8080/job/" + jenkins_job_name + "/" +  buildNum +"/console")
		while buildNum == job.get_current_build_number(jenkins_job_name).to_s do
			jenkins_status = job.get_current_build_status(jenkins_job_name) # running, success, failure
			if jenkins_status != "running"
				break
			end
			sleep(30)
		end
  	end

end



