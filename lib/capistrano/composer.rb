Capistrano::Configuration.instance(true).load do
  set :composer_path,     '/usr/local/bin/composer'
  set :composer_options,  '--no-scripts --no-dev --verbose --prefer-dist --optimize-autoloader --no-progress'

  depend :remote, :command, composer_path

  namespace :composer do
    desc 'Installs the project dependencies from the composer.lock file if present, or falls back on the composer.json.'
    task :install, :roles => :app, :except => { :no_release => true } do
      try_sudo "cd #{latest_release} && #{composer_path} install #{composer_options}"
    end

    desc 'Updates your dependencies to the latest version according to composer.json, and updates the composer.lock file.'
    task :update, :roles => :app, :except => { :no_release => true } do
      try_sudo "cd #{latest_release} && #{composer_path} update #{composer_options}"
    end

    desc 'Dumps an optimized autoloader.'
    task :dump_autoload, :roles => :app, :except => { :no_release => true } do
      try_sudo "cd #{latest_release} && #{composer_path} dump-autoload --optimize"
    end
  end
end
