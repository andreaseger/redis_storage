require 'rubygems'
require 'bundler/setup'

require 'lib/RedisRecord' # and any other gems you need
require 'redis'

RSpec.configure do |config|
  config.mock_with :mocha
  config.before(:all) do
    $db = Redis.new({})
  end
  config.before(:each) do
    $db.select 12
    $db.flushdb
  end
end
