ENV["REDISTOGO_URL"] ||= "redis://localhost:6379/"
uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :thread_safe => true)
Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
Resque.logger.formatter = Resque::VerboseFormatter.new
Resque.redis = "localhost:6379" # default localhost:6379
Resque::Plugins::Status::Hash.expire_in = (24 * 60 * 60) # 24hrs in seconds