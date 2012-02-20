require 'rubygems'
require 'bundler/setup'

require './lib/redis_storage' # and any other gems you need
require 'mock_redis'

RSpec.configure do |config|
  config.mock_with :mocha
  config.before(:all) do
    $db = MockRedis.new
  end
  config.before(:each) do
    $db.flushall
  end
end

shared_examples_for "ActiveModel" do
  require 'test/unit/assertions'
  require 'active_model/lint'
  include Test::Unit::Assertions
  include ActiveModel::Lint::Tests

  # to_s is to support ruby-1.9
  ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
    example m.gsub('_',' ') do
      send m
    end
  end

  def model
    subject
  end
end
