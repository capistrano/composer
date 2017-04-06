namespace :composer do
  desc <<-DESC
    Installs composer.phar to the shared directory
    In order to use the .phar file, the composer command needs to be mapped:
      SSHKit.config.command_map[:composer] = "\#{shared_path.join("composer.phar")}"
    This is best used after deploy:starting:
      namespace :deploy do
        after :starting, 'composer:install_executable'
      end
  DESC
  task :install_executable do
    on release_roles(fetch(:composer_roles)) do
      within shared_path do
        composer_version = fetch(:composer_version, nil)
        composer_version_option = composer_version ? "-- --version=#{composer_version}" : ""
        if test "[", "!", "-e", "composer.phar", "]"
          execute :curl, "-s", fetch(:composer_download_url), "|", :php, composer_version_option
        elsif composer_version
          current_version = capture(:php, "composer.phar", "-V", strip: false)
          unless current_version.include? "Composer version #{composer_version} "
            execute :curl, "-s", fetch(:composer_download_url), "|", :php, composer_version_option
          end
        end
      end
    end
  end

  desc <<-DESC
    Copies the vendor dir from the previous release. This speeds up deployment
    by not re-downloading packages that are available in the previous release.
    `composer install` will ensure that correct versions are being used.
    Note that if a package has been removed from composer.json since the previous
    release, using this task will cause it to be preserved in vendor/

    To use, add this to your deploy.rb:
      before "composer:install", "composer:copy_packages"
  DESC
  task :copy_packages do
    on release_roles(fetch(:composer_roles)) do
      # Only attempt to copy if there are previous releases (i.e. not on cold start)
      releases = capture("ls #{File.join(fetch(:deploy_to), 'releases')}")
      if previous_release = releases.split(/[\t\n]/).reject{|r| r == release_timestamp}.sort.last
        execute "vdir=#{current_path}/vendor; if [ -d $vdir ] || [ -h $vdir ]; then cp -a $vdir #{release_path}/vendor; fi"
      end
    end
  end

  task :run, :command do |t, args|
    args.with_defaults(:command => :list)
    on release_roles(fetch(:composer_roles)) do
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

  before 'deploy:updated', 'composer:install'
  before 'deploy:reverted', 'composer:install'
end

namespace :load do
  task :defaults do
    set :composer_install_flags, '--no-dev --prefer-dist --no-interaction --quiet --optimize-autoloader'
    set :composer_roles, :all
    set :composer_working_dir, -> { fetch(:release_path) }
    set :composer_dump_autoload_flags, '--optimize'
    set :composer_download_url, "https://getcomposer.org/installer"
  end
end
