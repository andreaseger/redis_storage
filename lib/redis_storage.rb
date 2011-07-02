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

    def self.index_for
      []
    end
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
      load(i) unless i.nil?
    end
    def self.find(params=nil)
      if params.nil?
        all
      else
        find_by :id, params   #TODO perhaps make this at some point more generic
      end
    end
    def self.find_by(key, value)
      if key == :id
        load "#{db_key}:#{value}"
      elsif index_for.include? key
        load($db.get("#{db_key}:#{key}:#{value.hash}"))
      else
        nil
      end
    end

    def self.all
      keys = $db.smembers(persisted_key)

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
      load $db.smembers(persisted_key).sort_by{|s| s.split(':')[1].to_i}.first
    end
    def self.last
      load $db.smembers(persisted_key).sort_by{|s| s.split(':')[1].to_i}.last
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
      delete!
      params.each do |key, value|
        send("#{key}=", value) unless key.to_sym == :id
      end
      save
    end
    def save
      if @id.nil?
        @id = $db.incr(self.class.next_id_key)
      end
      if valid?
        $db.multi do
          $db.set db_key, to_json
          $db.sadd self.class.persisted_key, db_key
          for key in self.class.index_for do
            $db.set "#{self.class.db_key}:#{key}:#{send(key).hash}", db_key
          end
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
          $db.srem self.class.persisted_key, db_key
          for key in self.class.index_for do
            $db.del "#{self.class.db_key}:#{key}:#{send(key).hash}"
          end
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
        $db.sismember(self.class.persisted_key, db_key)
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
    def self.load(key)
      return nil if key.nil?
      r = $db.get(key)
      new(JSON.parse(r)) unless r.nil?
    end
    def self.next_id_key
      "#{db_key}:next_id"
    end
  end
end
