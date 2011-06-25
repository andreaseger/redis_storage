require 'rubygems'
require 'test/unit'

require 'bundler'
Bundler.setup

require './lib/generators/rails/redis_generator'

class RedisGeneratorTest < Rails::Generators::TestCase
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination
  tests ::Rails::Generators::RedisGenerator

  test 'should create a model file with a few basic lines' do
    run_generator %w(Schedule title body created_at)
    assert_file 'app/models/schedule.rb', /class Schedule < RedisStorage::Model/
    assert_file 'app/models/schedule.rb', /attr_accessor \*attrs/
  end
  test 'should set the classes attrs' do
    run_generator %w(Schedule title body created_at)
    assert_file 'app/models/schedule.rb' do |model|
      assert_class_method :attrs, model do |attrs|
        assert_match /[ :id, :title, :body, :created_at ]/, attrs
      end
    end
  end
  test 'should set id as only class attribute if none given' do
    run_generator %w(Schedule title body)
    assert_file 'app/models/schedule.rb' do |model|
      assert_class_method :attrs, model do |attrs|
        assert_match /[ :title, :body ]/, attrs
      end
    end
  end
end
