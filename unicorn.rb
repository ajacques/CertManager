listen 3000
preload_app true
worker_processes 4

before_fork do |_server, _worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

after_fork do |_server, _worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end
