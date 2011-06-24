require 'redis_storage'
#require 'rails'
module RedisStorage
  class Railtie <::Rails::Railtie
    rake_tasks do
      load "tasks/redis_storage.rake"
    end
    if ::Rails.version.to_f >= 3.1
      config.app_generators.orm :redis
    else
      config.generators.orm :redis
    end
  end
end
