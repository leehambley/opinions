require 'opinions/version'
require 'singleton'
require 'redis'

module Opinions

  class << self
    attr_accessor :backend
  end

  module KeyBuilderExtensions

    def generate_key(scope, id = nil)
      [self.class.name, scope, id].compact.join(':')
    end

  end

  class KeyBuilder

    def initialize(args)
      @object  = args.fetch(:object)
      @target  = args.fetch(:target, nil)
      @opinion = args.fetch(:opinion)
    end

    def key
      object = @object.dup
      object.class.send(:include, KeyBuilderExtensions)
      key = object.generate_key(@opinion, object.id)
      if @target
        tcn = @target.class == Class ? @target.name : @target.class.name
        key += ":#{tcn}"
      end
      key
    end

  end

  class OpinionFactory
    attr_reader :key_name
    def initialize(key_name)
      @key_name = key_name
    end
    def opinion
      Opinions.backend.read_key(key_name).collect do |object_id, time|
        target_class_name, opinion, target_id, object_class_name = key_name.split ':'
        target_class, object_class = Kernel.const_get(target_class_name), Kernel.const_get(object_class_name)
        Opinion.new(target: target_class.find(target_id),
                    object: object_class.find(object_id),
                    opinion: opinion.to_sym,
                    created_at: time)
      end
    end
  end

  class RedisBackend

    attr_accessor :redis

    def write_keys(key_hashes)
      redis.multi do
        key_hashes.each do |key_name, hash|
          write_key(key_name, hash)
        end
      end
    end

    def write_key(key_name, hash)
      hash.each do |hash_key, hash_value|
        redis.hset key_name, hash_key, hash_value
      end
    end
    private :write_key

    def read_key(key_name)
      redis.hgetall(key_name)
    end

    def read_sub_key(key_name, key)
      redis.hget(key_name, key)
    end

    def remove_sub_keys(key_pairs)
      redis.multi do
        key_pairs.each do |key_name, key|
          redis.hdel(key_name, key.to_s)
        end
      end
    end

    def keys_matching(argument)
      redis.keys(argument)
    end

  end

  class KeyLoader

    def initialize(key)
      @object_class, @opinion, @object_id, @target_class = key.split(':')
    end

    def object
      Object.const_get(@object_class).find(_object_id)
    end

    private

      def _object_id
        @object_id.to_i == @object_id ? @object_id : @object_id.to_i
      end

  end

  class Opinion

    attr_accessor :target, :object, :opinion, :created_at

    def initialize(args = {})
      @target, @object, @opinion, @created_at =
        args.fetch(:target), args.fetch(:object), args.fetch(:opinion), args.fetch(:created_at, nil)
      self
    end

    def persist(args = {time: Time.now})
      backend.write_keys({
        target_key => {object.id.to_s => args.fetch(:time)},
        object_key => {target.id.to_s => args.fetch(:time)},
      })
    end

    def object_key
      KeyBuilder.new(object: object, opinion: opinion, target: target).key
    end

    def target_key
      KeyBuilder.new(object: target, opinion: opinion, target: object).key
    end

    def exists?
      tk = backend.read_sub_key(target_key, object.id.to_s)
      ok = backend.read_sub_key(object_key, target.id.to_s)
      tk && ok
    end

    def remove
      backend.remove_sub_keys([[target_key, object.id.to_s],
                               [object_key, target.id.to_s]])
    end

    def ==(other_opinion)
      raise ArgumentError, "Can't compare a #{other_opinion} with #{self}" unless other_opinion.is_a?(Opinion)
      opinion_equal  = self.opinion == other_opinion.opinion
      opinion_target = self.target  == other_opinion.target
      opinion_object = self.object  == other_opinion.object
      opinion_equal && opinion_target && opinion_object
    end

    private

      def backend
        Opinions.backend
      end

  end

  module Pollable

    class << self

      def included(klass)
        klass.send(:include, InstanceMethods)
        klass.send(:extend,  ClassMethods)
      end

    end

    module ClassMethods
      def opinions(*opinions)
        opinions.each { |opinion| register_opinion(opinion.to_sym) }
      end
      def register_opinion(name)
        @registered_opinions ||= Array.new
        @registered_opinions <<  name
      end
      def registered_opinions
        @registered_opinions
      end
    end

    module InstanceMethods

      def initialize(*args)
        super
        self.class.registered_opinions.each do |opinion|
          self.class.send :define_method, :"#{opinion}_by" do |*args|
            opinional, time = *args
            time            = time || Time.now.utc
            e = Opinion.new(object: opinional, target: self, opinion: opinion)
            true & e.persist(time: time)
          end
          self.class.send :define_method, :"cancel_#{opinion}_by" do |opinional|
            Opinion.new(object: opinional, target: self, opinion: opinion).remove
          end
         self.class.send :define_method, :"#{opinion}_votes" do
           lookup_key_builder = KeyBuilder.new(object: self, opinion: opinion)
           keys = Opinions.backend.keys_matching(lookup_key_builder.key + "*")
           keys.collect do |key_name|
             OpinionFactory.new(key_name).opinion
           end.flatten
         end
        end
      end

    end

  end

  module Opinionated

    def self.included(klass)
      klass.send(:include, InstanceMethods)
      klass.send(:extend,  ClassMethods)
    end

    module ClassMethods

    end

    module InstanceMethods

    end

  end

end
