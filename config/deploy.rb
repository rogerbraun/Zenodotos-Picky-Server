# -*- encoding : utf-8 -*-
require "bundler/capistrano"
require "capistrano/ext/multistage"
#require "rvm/capistrano"                  # Load RVM's capistrano plugin.

set :application, "Zenodotos"
set :repository,  "git://github.com/rogerbraun/Zenodotos-Picky-Server.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "rokuhara.japanologie.kultur.uni-tuebingen.de"                          # Your HTTP server, Apache/etc
role :app, "rokuhara.japanologie.kultur.uni-tuebingen.de"                          # This may be the same as your `Web` server
role :db,  "rokuhara.japanologie.kultur.uni-tuebingen.de", :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_via, :remote_cache
set :user, "edv"
set :use_sudo, false

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
end
