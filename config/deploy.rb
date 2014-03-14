# config valid only for Capistrano 3.1
lock '3.1.0'

set :deploy_via, :remote_cache
set :use_sudo, true
set :user, 'devops'
set :deployer_user, 'deployer'

set :application, 'blog'
set :repo_url, 'https://github.com/barakarg/blog'

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
      execute "sudo sv 2 /home/#{fetch(:deployer_user)}/service/#{fetch(:application)}"
    end
  end

  after :publishing, :upload_env_vars do
    on roles(:app), in: :sequence, wait: 5 do
      upload!(".env.#{fetch(:rails_env)}", "#{fetch(:release_path)}/.env.#{fetch(:rails_env)}", :via => :scp)
    end
  end
  
  after :started, :set_permissions do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "chown -R #{fetch(:user)} #{fetch(:deploy_to)} && chmod -R g+s #{fetch(:deploy_to)}"
    end
  end

  after :publishing, :restart
end
