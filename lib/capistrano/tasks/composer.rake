namespace :composer do

desc <<-DESC
    Check wether composer is installed globally or not.
    This test should be executed everytime.
  DESC
  task :check do
    on release_roles(fetch(:composer_roles)) do
      info "Testing if composer is installed globally"
      if test "[[ -n `which composer` ]]"
        invoke 'composer:install_executable'
      end
    end
  end

  desc <<-DESC
    Installs composer.phar to the composer_path directory
    The advantage of using a variable is that we have better control on the path used in SSHKit.

    In order to use the .phar file, the composer command is mapped using the composer_path variable:
      SSHKit.config.command_map[:composer] = "php \#{fetch(composer_path)}/composer.phar"

    This is best used after deploy:starting:
      namespace :deploy do
        after :starting, 'composer:install_executable'
      end
  DESC
  task :install_executable do
    on release_roles(fetch(:composer_roles)) do

      within fetch(:composer_path) do
        unless test "[", "-e", "composer.phar", "]"
          set :should_install_composer, ask('Do you want to install composer locally ?', 'y|n')
          unless fetch(:should_install_composer) != 'y'
            composer_version = fetch(:composer_version, nil)
            composer_version_option = composer_version ? "-- --version=#{composer_version}" : ""
            execute :curl, "-s", fetch(:composer_download_url), "|", :php, composer_version_option
          else
            error("You need composer in order to continue")
            abort()
          end
        end
      end
    end
  end

  task :run, :command do |t, args|
    args.with_defaults(:command => :list)
    on release_roles(fetch(:composer_roles)) do
      if fetch(:composer_use_global)
        execute :echo, "Using globally installed composer at ", `which composer`
      else
        set :composer_exec_path, "php #{fetch(:composer_path)}/composer.phar"
        execute :echo, fetch(:composer_exec_path)
        SSHKit.config.command_map[:composer] = fetch(:composer_exec_path)
      end
      within fetch(:composer_working_dir) do
        execute :composer, args[:command], *args.extras
      end
    end
  end

  desc <<-DESC
        Install the project dependencies via Composer. By default, require-dev \
        dependencies will not be installed.

        You can override any of the defaults by setting the variables shown below.

          set :composer_install_flags, '--no-dev --no-interaction --quiet --optimize-autoloader'
          set :composer_roles, :all
    DESC
  task :install do
    invoke "composer:run", :install, fetch(:composer_install_flags)
  end

  task :dump_autoload do
    invoke "composer:run", :dumpautoload, fetch(:composer_dump_autoload_flags)
  end

  desc <<-DESC
        Run the self-update command for composer.phar

        You can update to a specific release by setting the variables shown below.

          set :composer_version, '1.0.0-alpha8'
    DESC
  task :self_update do
    invoke "composer:run", :selfupdate, fetch(:composer_version, '')
  end

  before 'composer:run', 'composer:check'
  before 'deploy:updated', 'composer:install'
  before 'deploy:reverted', 'composer:install'
end

namespace :load do
  task :defaults do
    set :composer_install_flags, '--no-dev --prefer-dist --no-interaction --quiet --optimize-autoloader'
    set :composer_roles, :all
    set :composer_dump_autoload_flags, '--optimize'
    set :composer_download_url, "https://getcomposer.org/installer"
    # use ruby global variables in a lambda
    set :composer_working_dir, -> { "#{release_path}" }
    set :composer_path, -> { "#{shared_path}" }
    set :composer_use_global, false
  end
end
