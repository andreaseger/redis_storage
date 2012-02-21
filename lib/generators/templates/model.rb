class <%= class_name %> < RedisStorage::Model
  attribute <%= ':' unless attrs.empty? %><%= attrs.map{|e| e.split(':')[0]}.join(', :') %>
end
