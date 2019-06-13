rails_env = ENV['RAILS_ENV'] || "production"

if rails_env == 'production'
  # workers 数改成实际 CPU 数，可通过 grep -c processor /proc/cpuinfo 查询
  threads 1, 6
  daemonize true
  environment rails_env
  app_dir = File.expand_path("../..", __FILE__)
  shared_dir = "#{app_dir}/shared"
  bind "unix://#{shared_dir}/sockets/puma.sock"
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true
  pidfile "#{shared_dir}/pids/puma.pid"
  state_path "#{shared_dir}/pids/puma.state"
  port 30000

  on_worker_boot do
    require "active_record"
    ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
    ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
  end
else
  threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
  threads threads_count, threads_count
  port        ENV.fetch("PORT") { 3000 }
  environment ENV.fetch("RAILS_ENV") { "development" }
  plugin :tmp_restart
end





