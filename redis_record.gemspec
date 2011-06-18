# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_record/version"

Gem::Specification.new do |s|
  s.name        = "redis_record"
  s.version     = RedisRecord::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andreas Eger"]
  s.email       = ["dev@eger-andreas.de"]
  s.homepage    = ""
  s.summary     = %q{A simple Redis ORM for Rails}
  s.description = %q{Provides a DataMapper for a Redis Backend in Rails, will also provide a Generator}

  s.add_dependency 'redis'
  s.add_dependency 'json'
  s.add_development_dependency 'rspec'

  s.rubyforge_project = "redis_record"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
