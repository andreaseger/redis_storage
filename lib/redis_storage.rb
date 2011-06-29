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
      i = $db.srandmember(persisted_key)
      find_by_id(i) unless i.nil?
    end
    def self.find(params=nil)
      if params.nil?
        all
      else
        find_by_id(params)   #TODO perhaps make this at some point more generic
      end
    end
    def self.find_by(key, value)
      return nil if key.nil? || value.nil?
      find_by_id($db.get("#{db_key}:#{key}:#{value}"))
    end
    def self.find_by_id(entry_id)
      return nil if entry_id.nil?
      r = $db.get("#{db_key}:#{entry_id}")
      new(JSON.parse(r)) unless r.nil?
    end

    def self.all
      keys = $db.smembers(persisted_key).map do |i|
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

    def self.count
      $db.scard(persisted_key)
    end
    def self.first
      find_by_id $db.smembers(persisted_key).sort.first
    end
    def self.last
      find_by_id $db.smembers(persisted_key).sort.last
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
        @id = $db.incr(self.class.next_id_key)
      end
      if valid?
        $db.multi do
          $db.set db_key, to_json
          $db.sadd self.class.persisted_key, id
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
          $db.srem self.class.persisted_key, id
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
        $db.sismember(self.class.persisted_key, id)
      end
    end

    def self.db_key
      model_name
    end
    def db_key
      "#{self.class.db_key}:#{self.id}"
    end
    def self.persisted_key
      "#{db_key}:persisted"
    end

    def initialize(params={})
      @id = nil
      @errors = ActiveModel::Errors.new(self)
      params.each do |key, value|
        send("#{key}=", value)
      end
    end
    private
    def self.next_id_key
      "#{db_key}:next_id"
    end
  end
end
