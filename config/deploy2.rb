# config valid only for Capistrano 3.1
lock '3.1.0'

set :deploy_via, :remote_cache
set :use_sudo, true
set :user, 'deployer'

set :application, 'blog'
set :repo_url, 'git@example.com:me/my_repo.git'
set :branch, 'development'

set :deploy_to, "/var/www/#{fetch(:application)}"

set :pty, true

set :rake, "#{fetch(:rake)} --trace"

set :bundle_without, [:development, :test, :acceptance]

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :default_env, { path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH" }

# after 'deploy:update_code', :upload_env_vars

after 'deploy:setup' do
  sudo "chown -R #{user} #{deploy_to} && chmod -R g+s #{deploy_to}"
end

namespace :deploy do
  desc <<-DESC
  Send a USR2 to the unicorn process to restart for zero downtime deploys.
  runit expects 2 to tell it to send the USR2 signal to the process.
  DESC
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sv 2 /home/#{user}/service/#{application}"
  end
end

task :upload_env_vars do
  upload(".env.#{rails_env}", "#{release_path}/.env.#{rails_env}", :via => :scp)
end