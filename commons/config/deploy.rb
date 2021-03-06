require 'capistrano_colors'

set :stage_dir, 'commons/config/deploy'
set :stages, %w(prod)
set :default_stage, "prod"
require 'capistrano/ext/multistage'

set :application, "myApp"

remote = ENV['REMOTE'] ? ENV['REMOTE'] : 'origin'
set :repository, `git remote -v | grep fetch | grep #{remote} | xargs -n 1 | tail -2 | head -n 1`.strip
set :git_enable_submodules, 1
set :git_submodules_recursive, 1
set :branch, `git branch | grep ^*`.strip.gsub('* ','')

set :copy_exclude, [ ".git" ]
set :deploy_via,        :remote_cache
set :use_sudo, false

set :shared_children,   [
]
set :asset_children, []
set :shared_files,      [
  "commons/config/parameters.yml"
]

set :model_manager, "propel"
set :update_vendors, false
set :use_composer, true

set :apps, %w(frontend backend)

before 'symfony:composer:install', 'composer:copy_vendors'
before 'symfony:composer:update', 'composer:copy_vendors'

namespace :composer do
  task :copy_vendors, :except => { :no_release => true } do
    pretty_print "--> Copy vendor file from previous release"

    run "vendorDir=#{current_path}/vendor; if [ -d $vendorDir ] || [ -h $vendorDir ]; then cp -a $vendorDir #{latest_release}/vendor; fi;"
    puts_ok
  end
end



