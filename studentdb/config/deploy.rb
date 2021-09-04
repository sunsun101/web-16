# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.16.0'

set :application, 'studentdb'
set :repo_url, 'git@gitlab.com:ait-wae-2021/web16/web16-app'
set :rbenv_type, :user
set :rbenv_ruby, '3.0.2'
set :repo_tree, 'studentdb'
set :branch, ENV['BRANCH'] || 'main'

append :linked_files, 'config/database.yml', 'config/master.key', 'config/client_secrets.json', 'config/tokens.json'

append :linked_dirs, 'log', 'tmp', 'public/system', 'public/assets', 'public/packs', '.bundle'

set :keep_releases, 5

after 'deploy:publishing', 'puma:restart'
