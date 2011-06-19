class <%= class_name %> < RedisRecord::Model
  def self.attrs
    [ :id<%=", :" unless attrs.empty?%><%= attrs.join(', :') %> ]
  end
  attr_accessor *attrs

  def self.db_key
    "<%= file_name %>"
  end
end
