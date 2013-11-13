namespace :composer do
  desc <<-DESC
    Installs composer.phar to the shared directory
    In order to use the .phar file, the composer command needs to be mapped:
      SSHKit.config.command_map[:composer] = "\#{shared_path.join("composer.phar")}"
    This is best used before deploy:starting:
      namespace :deploy do
        before :starting, 'composer:install_executable'
      end
  DESC
  task :install_executable do
    on roles fetch(:composer_roles) do
      within shared_path do
        unless test "[", "-e", "composer.phar", "]"
          execute :curl, "-s", fetch(:composer_download_url), "|", :php
        end
      end
    end
  end

  task :run, :command do |t, args|
    args.with_defaults(:command => :list)
    on roles fetch(:composer_roles) do
      within release_path do
        execute :composer, args[:command], *args.extras
      end
    end
  end

  desc <<-DESC
        Install the project dependencies via Composer. By default, require-dev \
        dependencies will not be installed.

        You can override any of the defaults by setting the variables shown below.

          set :composer_flags, '--no-dev --no-scripts --quiet --optimize-autoloader'
          set :composer_roles, :all
    DESC
  task :install do
    invoke "composer:run", :install, fetch(:composer_install_flags)
  end

  task :copy_from_previous_release do
    next unless fetch(:composer_copy_previous_vendors)
    on roles fetch(:composer_roles) do
      last_release = capture(:ls, '-xr', releases_path).split.fetch(1, nil)
      next unless last_release
      last_release_path = releases_path.join(last_release)

      if test "[ -d #{last_release_path.join('vendor')} ]"
        within last_release_path do
          execute :cp, "-R", "vendor", release_path.join('vendor')
        end
      end
    end
  end

  task :dump_autoload do
    invoke "composer:run", :dumpautoload, fetch(:composer_dump_autoload_flags)
  end

  desc "Run the self-update command for composer.phar"
  task :self_update do
    invoke "composer:run", :selfupdate
  end

  before 'deploy:updated', 'composer:copy_from_previous_release'
  before 'deploy:updated', 'composer:install'
end

namespace :load do
  task :defaults do
    set :composer_install_flags, '--no-dev --prefer-dist --no-scripts --quiet --optimize-autoloader'
    set :composer_roles, :all
    set :composer_dump_autoload_flags, '--optimize'
    set :composer_download_url, "https://getcomposer.org/installer"
    set :composer_copy_previous_vendors, true
  end
end
