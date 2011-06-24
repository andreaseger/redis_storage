class <%= class_name %> < RedisStorage::Model
  def self.attrs
    [ :id<%=", :" unless attrs.empty?%><%= attrs.join(', :') %> ]
  end
  attr_accessor *attrs
end
