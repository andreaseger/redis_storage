class <%= class_name %> < RedisRecord::Model
  def self.attrs
    [ :id<%=", :" unless attrs.empty?%><%= attrs.join(', :') %> ]
  end
  attr_accessor *attrs

  def db_key
    "<%= file_name %>:#{self.id}"
  end
end
