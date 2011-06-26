require 'json'
require 'active_model'

module RedisStorage
  require 'redis_storage/railtie' if defined?(Rails)

  class Model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    validates_presence_of :id

    def self.attrs
      []
    end

    attr_accessor *attrs
    attr_accessor :id
    attr_reader :errors

    def self.build(params)
      new params
    end

    def self.create(params)
      obj = build params
      obj.save
      obj
    end

    def self.random
      i = $db.srandmember("#{db_key}:persisted")
      find_by_id(i) unless i.nil?
    end
    def self.find(params=nil)
      if params.nil?
        all
      else
        find_by_id(params)   #TODO perhaps make this at some point more generic
      end
    end
    def self.find_by_id(entry_id)
      r = $db.get("#{db_key}:#{entry_id}")
      new(JSON.parse(r)) unless r.nil?
    end

    def self.all
      keys = $db.smembers("#{db_key}:persisted").map do |i|
        "#{db_key}:#{i}"
      end

      if keys.empty?
        []
      else
        $db.mget(*keys).inject([]) do |a,json|
          a << new(JSON.parse(json))
        end
      end
    end

    def serializable_hash
      self.class.attrs.inject({:id => @id}) do |a,key|
        a[key] = send(key)
        a
      end
    end
    def to_json
      serializable_hash.to_json
    end

    def update_attributes(params)
      params.each do |key, value|
        send("#{key}=", value) unless key.to_sym == :id
      end
      save
    end
    def save
      unless persisted?
        @id = $db.incr("#{db_key}:nextid")
      end
      if valid?
        $db.multi do
          $db.set db_key, serializable_hash.to_json
          $db.sadd "#{self.class.db_key}:persisted", id
        end
        @id
      else
        nil
      end
    end

    def destroy
      delete!     #for the default rails controller
    end
    def delete!
      if persisted?
        $db.multi do
          $db.del db_key
          $db.srem "#{self.class.db_key}:persisted", id
        end
        true
      else
        false
      end
    end

    def persisted?
      if id.nil?
        false
      else
        $db.sismember("#{self.class.db_key}:persisted", id)
      end
    end

    def self.db_key
      model_name
    end
    def db_key
      "#{self.class.db_key}:#{self.id}"
    end

    def initialize(params={})
      @id = nil
      @errors = ActiveModel::Errors.new(self)
      params.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end
