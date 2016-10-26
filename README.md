# Capistrano::Composer

Composer support for Capistrano 3.x

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano', '~> 3.1.0'
gem 'capistrano-composer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-composer

## Usage

Require the module in your `Capfile`:

```ruby
require 'capistrano/composer'
```

`capistrano/composer` comes with 5 tasks:

* composer:install
* composer:install_executable
* composer:dump_autoload
* composer:self_update
* composer:run

The `composer:install` task will run before deploy:updated as part of
Capistrano's default deploy, or can be run in isolation with:

```bash
$ cap production composer:install
```

By default it is assumed that you have the Composer executable installed and in your
`$PATH` on all target hosts.

### Configuration

Configurable options, shown here with defaults:

```ruby
set :composer_install_flags, '--no-dev --no-interaction --quiet --optimize-autoloader'
set :composer_roles, :all
set :composer_working_dir, -> { fetch(:release_path) }
set :composer_dump_autoload_flags, '--optimize'
set :composer_download_url, 'https://getcomposer.org/installer'
set :composer_version, '1.0.0-alpha8' # (default: not set)
set :composer_bin, 'bin/composer.phar' # (default: not set)
set :composer_php, 'php5' # (default: not set)
```

### Installing Composer as part of a deployment

To install Composer as part of the deployment, set `:composer_bin` to `:local`.
This ensures installation of a local `composer.phar` in the shared path.

### Accessing Composer commands directly

This library also provides a `composer:run` task which allows access to any
Composer command.

From the command line you can run

```bash
$ cap production composer:run[status,--profile]
```

Or from within a rake task using Capistrano's `invoke`

```ruby
task :my_custom_composer_task do
  invoke 'composer:run', :update, '--dev --prefer-dist'
end
```

### Removing the default install task

If you do not want to run the default install task on `deploy:updated`, (for 
example, if you do not have root level dependencies stored in a `composer.json`
you can remove it by adding the following line to your `config/deploy.rb`:

```ruby
Rake::Task['deploy:updated'].prerequisites.delete('composer:install')
```

You can then call `composer.install` task within your own defined tasks, at an 
appropriate juncture.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
