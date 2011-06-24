# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_storage/version"

Gem::Specification.new do |s|
  s.name        = "redis_storage"
  s.version     = RedisStorage::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andreas Eger"]
  s.email       = ["dev@eger-andreas.de"]
  s.homepage    = "https://github.com/sch1zo/redis_storage"
  s.summary     = %q{A simple Redis ORM for Rails}
  s.description = %q{Provides a databackend for a Redis in Rails, will also provide a Rails 3 Generator}

  s.add_dependency 'redis'
  s.add_dependency 'json'
  s.add_dependency 'activemodel', '>= 3.0.0'

  s.add_development_dependency 'rspec', '>= 2.0.0'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'autotest'
  s.add_development_dependency 'redis'
  s.add_development_dependency 'rails', '>= 3.0.0'

  s.rubyforge_project = "redis_storage"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
