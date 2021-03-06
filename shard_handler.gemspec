# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shard_handler/version'

Gem::Specification.new do |spec|
  spec.name          = 'shard_handler'
  spec.version       = ShardHandler::VERSION
  spec.authors       = ['Lenon Marcel', 'Rafael Timbó', 'Lucas Nogueira',
                        'Rodolfo Liviero']
  spec.email         = ['lenon.marcel@gmail.com', 'rafaeltimbosoares@gmail.com',
                        'lukspn.27@gmail.com', 'rodolfoliviero@gmail.com']
  spec.summary       = 'A simple sharding solution for Rails applications'
  spec.description   = 'A simple sharding solution for Rails applications'
  spec.homepage      = 'https://github.com/locaweb/shard_handler'
  spec.license       = 'MIT'

  spec.files         = Dir['LICENSE.txt', 'README.md', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 4.2.0'
  spec.add_dependency 'activesupport', '~> 4.2.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'yard'
end
