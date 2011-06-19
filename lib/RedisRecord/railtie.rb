require 'RedisRecord'
require 'rails'
module RedisRecord
  class Railtie <::Rails::Railtie
    rake_tasks do
      load "tasks/RedisRecord.rake"
    end
  end
end
