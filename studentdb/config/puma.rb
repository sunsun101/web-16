# frozen_string_literal: true

# Get Rails environment

rails_env = ENV.fetch('RAILS_ENV', 'development')
environment rails_env

# If production mode, use two workers with preloaded application

if rails_env == 'production'
  ENV['https_proxy'] = 'http://192.41.170.23:3128'
  ENV['http_proxy'] = 'http://192.41.170.23:3128'
  workers 2
  preload_app!
  state_path 'tmp/sockets/puma.state'
  # Location of the control socket. Must be created in advance.
  app_dir = File.expand_path('..', __dir__)
  bind "unix://#{app_dir}/tmp/sockets/puma.sock"
end

# 1-5 threads per worker

threads 1, 5

# Run on port 3000 by default

port ENV.fetch('PORT', 3000)

# Specify the server's PID file

pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Allow puma to be restarted by the "rails restart" command

plugin :tmp_restart

# Activate the control app

activate_control_app
