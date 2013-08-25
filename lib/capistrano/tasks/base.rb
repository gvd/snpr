namespace :deploy do
  task :set_symlinks do
    ln("#{shared_path}/config/app_config.yml", "#{release_path}/config/app_config.yml")
    ln("#{shared_path}/config/database.yml", "#{release_path}/config/database.yml")
    mkdir("#{release_path}/solr/pids")
    ln("#{shared_path}/pids", "#{release_path}/solr/pids/production")
  end
  after "deploy:create_shared_dirs", "deploy:set_symlinks"

  task :create_shared_dirs do
    mkdir("#{shared_path}/config")
  end
  after "deploy:update_code", "deploy:create_shared_dirs"
end
