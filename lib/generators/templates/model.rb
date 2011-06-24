class <%= class_name %> < RedisStorage::Model
  def self.attrs
    [ :id<%=", :" unless attrs.empty?%><%= attrs.map{|e| e.split(':')[0]}.join(', :') %> ]
  end
  attr_accessor *attrs
end
