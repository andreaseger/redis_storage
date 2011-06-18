class <%= class_name %> < RedisRecord::Model
  def self.attrs
    [ :id<%= a %> ]
  end
  attr_accessor *attrs

  def db_key
    "<%= file_name %>:#{self.id}"
  end
end
