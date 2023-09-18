# frozen_string_literal: true

require_relative "noomer/version"

module Noomer
  def self.included(base) = base.extend(ClassMethods)

  attr_reader :value

  def initialize(value = nil)
    @value = value
  end

  module ClassMethods
    attr_reader :type_holder

    def enum(type = nil)
      Class.new(self) do
        self.type_holder = TypeHolder.new(type) if type
      end
    end

    private

    attr_writer :type_holder

    def registry = @registry ||= Registry.new

    def const_added(const)
      constant = const_get(const)
      return unless constant.is_a?(Class)
      return unless constant < self

      type = constant.type_holder&.type
      defn = case type
      when Class
        proc do |instance|
          raise ArgumentError unless instance.is_a?(type)
          registry.fetch(instance) { constant.new(instance).freeze }
        end
      when nil
        proc do
          registry.fetch(constant) { constant.new.freeze }
        end
      else
        proc do
          registry.fetch(type) { constant.new(type).freeze }
        end
      end
      self.class.define_method(const, &defn)
    end
  end

  class Registry
    def initialize = @registry = {}

    def fetch(key, &blk) = @registry[key] ||= blk.call
  end
  private_constant :Registry

  class TypeHolder
    attr_reader :type

    def initialize(type) = @type = type
  end
  private_constant :TypeHolder
end
