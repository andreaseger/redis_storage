desc "copies an initializer for redis into the app"
task :install_redis do
  init <<-INIT
c = YAML.load_file("\#{::Rails.root.to_s}/config/ldap.yml")[::Rails.env]
redis_config = { :host => c['host'], :port => c['port'], :password => c['password'], :db => c['db'] }

$db = Redis.new(redis_config)
  INIT
  yml <<-YAML
development:
  host: "localhost"
  port: 6379
  password:
  db: 3
test:
  host: "localhost"
  port: 6379
  password:
  path: 12
productive:
  host: "localhost"
  port: 6379
  password:
  path: 1
  YAML
  File.open('config/initializers/redis.rb', 'w') {|f| f.write(init) }
  File.open('config/redis.yml', 'w') {|f| f.write(yml) }
end
