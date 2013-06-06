# capistrano-composer

capistrano-composer is a [Capistrano](https://github.com/capistrano/capistrano) extension that will let you use [Composer](http://getcomposer.org/) to manage your dependencies during your deploy process.

## Installation

1. Install the Gem

```bash
gem install capistrano-composer`
```

Or if you're using Bundler, add it to your `Gemfile`:

```ruby
gem 'capistrano-composer', github: 'swalkinshaw/composer'
```

2. Add to `Capfile` or `config/deploy.rb`:

```ruby
require 'capistrano/composer'
```

## Usage

Add the task to your `deploy.rb`:

```ruby
after 'deploy:finalize_update', 'composer:install'
```

### Tasks

* `composer:install`: Installs the project dependencies from the composer.lock file if present, or falls back on the composer.json.
* `composer:update`: Updates your dependencies to the latest version according to composer.json, and updates the composer.lock file.
* `composer:dump_autoload`: Dumps an optimized autoloader.

## Configuration

* `composer_path`: Path to the Composer bin (defaults to `/usr/local/bin/composer`)
* `composer_options`: Options passed to composer command (defaults to `--no-scripts --no-dev --verbose --prefer-dist --optimize-autoloader --no-progress`)

