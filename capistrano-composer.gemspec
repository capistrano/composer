# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'capistrano/composer/version'

Gem::Specification.new do |s|
  s.name          = 'capistrano-composer'
  s.version       = Capistrano::Composer::VERSION
  s.authors       = ['Scott Walkinshaw']
  s.email         = ['scott.walkinshaw@gmail.com']
  s.homepage      = 'https://github.com/swalkinshaw/capistrano-composer'
  s.summary       = %q{Capistrano extension that adds Composer tasks}
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.require_paths = %w(lib)

  s.add_dependency 'capistrano', '>= 2.5.5'
end
