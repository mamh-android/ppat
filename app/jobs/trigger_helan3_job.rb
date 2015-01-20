require 'net/http'
class TriggerHelan3Job < Resque::JobWithStatus
	include Resque::Plugins::Status
	@queue = :helan3
	#send url request to jenkins, wait until jenkins job finished
  	def perform
	  	jenkins_url = "http://10.38.32.97:3000/scenarios"
	    url = URI.parse(jenkins_url)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		fh = File.new("temp_2.out", "w")
		fh.puts options['platform']
		fh.close
		completed('result' => 'false')
  	end

end



