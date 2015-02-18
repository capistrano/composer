# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-composer'
  spec.version       = '0.0.6'
  spec.authors       = ['Scott Walkinshaw', 'Peter Mitchell']
  spec.email         = ['scott.walkinshaw@gmail.com', 'peterjmit@gmail.com']
  spec.description   = %q{Composer support for Capistrano 3.x}
  spec.summary       = %q{Composer support for Capistrano 3.x}
  spec.homepage      = 'https://github.com/capistrano/composer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '>= 3.0.0.pre'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.1'
end
