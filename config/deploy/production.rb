set :rails_env, 'production'
set :branch, 'master'

server '127.0.0.1',
  port: '2222',
  roles: %w{web app},
  ssh_options: {
    user: 'vagrant',
    password: 'vagrant',
    # keys: %w(/home/deployer/.ssh/id_rsa),
    forward_agent: false,
    auth_methods: %w(password)
    # password: 'please use keys'
  }
