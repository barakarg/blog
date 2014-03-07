# config valid only for Capistrano 3.1
lock '3.1.0'

set :deploy_via, :remote_cache
set :use_sudo, true
set :user, 'deployer'

set :application, 'blog'
set :repo_url, 'git@example.com:me/my_repo.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, "/var/www/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :default_env, { path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      run "sv 2 /home/#{user}/service/#{application}"
    end
  end

  after :publishing, :upload_env_vars do
    upload(".env.#{rails_env}", "#{release_path}/.env.#{rails_env}", :via => :scp)
  end
  
  after :started, :set_permissions do
    sudo "chown -R #{user} #{deploy_to} && chmod -R g+s #{deploy_to}"
  end

  after :publishing, :restart
end
