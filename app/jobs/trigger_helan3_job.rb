require 'net/http'
require 'net/ftp'
require 'open-uri'
require 'jenkins_api_client'
class TriggerHelan3Job < Resque::JobWithStatus
	include Resque::Plugins::Status
	@queue = :helan3
	#send url request to jenkins, wait until jenkins job finished
  	def perform
 		#build job
		client = JenkinsApi::Client.new(:server_ip => '10.38.120.30', :username => 'ppat', :password => '79fa7f655d56115da6fe7d707f63fd12')
		build_que = JenkinsApi::Client::BuildQueue.new(client)
		device = options['device'].split(":")[0]
		image_path = options['image_path']
		android_ver = /-[\w]+\.\d+/.match(image_path)[0]
		rls_ver = image_path[10, image_path.length]
		puts image_path.chomp
		os_version = android_ver[1, android_ver.length]
		idx = image_path.index(/-[\w]+\.\d+/) + 1 + android_ver.length
		if idx < image_path.length
			rls_ver = image_path[idx, image_path.length]
			if rls_ver.include? "/"
				rls =  rls_ver.chop
			end
		else
			rls_ver = "master"
		end
		job_params = {
		    'IMAGEPATH' => image_path,
		    'PURPOSE' => options['purpose'],
		    'BLF' => options['blf'],
		    'OS' => os_version,
		    'RLS_VERSION' => rls_ver,
		    'DEVICE' => device,
		    'TESTCASE' => options['testcase'],
		    'ASSIGNER' => options['assigner']
		}
		opts = {}
		#check whether jenkins is running
		job = JenkinsApi::Client::Job.new(client)
		jenkins_job_name = ""
		hw = options['hw'].to_s
		if hw == 'HELAN3_1: Daily use'
			jenkins_job_name = "PPAT_HELN3"
		elsif hw == 'HELAN3_2: Camera OV13850'
			jenkins_job_name = "PPAT_HELN3_camera"
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



