# frozen_string_literal: true

set :default_env, { 'http_proxy' => '192.41.170.23:3128',
                    'https_proxy' => '192.41.170.23:3128',
                    'BAZOOKA_USER' => ENV['USER'] }

server 'web16', user: 'deploy', roles: %w[app db web]

set :deploy_to, '/home/deploy/studentdb'

# set :yarn_flags, '--production --silent --no-progress --network-timeout 1000000'
