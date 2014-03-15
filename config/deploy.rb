# config valid only for Capistrano 3.1
lock '3.1.0'

set :deploy_via, :remote_cache
set :user, 'devops'

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
      execute "sudo sv 2 /home/#{fetch(:user)}/service/#{fetch(:application)}"
    end
  end

  desc 'Upload environment variables'
  task :upload_env_vars do
    on roles(:app), in: :sequence, wait: 5 do
      upload!(".env.#{fetch(:rails_env)}", "#{fetch(:release_path)}/.env.#{fetch(:rails_env)}", :via => :scp)
    end
  end

  # desc "Migrate DB"
  # task :migrate_db do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     run "cd #{fetch(:release_path)} && bundle exec rake db:migrate RAILS_ENV=production"
  #   end
  # end
  
  # desc "Bundle gems"
  # task :bundle_install do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     run "cd #{fetch(:release_path)} && bundle install"
  #   end
  # end
  
  desc "Set permissions to deployed files"
  task :set_permissions do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "chown -R #{fetch(:user)} #{fetch(:deploy_to)} && chmod -R g+s #{fetch(:deploy_to)}"
    end
  end

  after :started, :set_permissions

  after :publishing, :upload_env_vars
  # after :publishing, :bundle_install
  # after :publishing, :migrate_db
  
  after :published, :restart

end
