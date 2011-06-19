require 'RedisRecord'
require 'rails'
module RedisRecord
  class Railtie <::Rails::Railtie
    railtie_name :RedisRecord

    rake_tasks do
      load "tasks/RedisRecord.rake"
    end
  end
end
