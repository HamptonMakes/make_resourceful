require 'resourceful/builder'

module Resourceful
  # This module contains mixin modules
  # used to implement the object serialization
  # used for the Builder#publish method.
  # They can also be used as generic ways
  # to get serialized representations of objects.
  module Serialize
    
    def self.normalize_attributes(attributes) # :nodoc:
      return nil if attributes.nil?
      return {attributes.to_sym => nil} if String === attributes
      return {attributes => nil} if !attributes.respond_to?(:inject)

      attributes.inject({}) do |hash, attr|
        if Array === attr
          hash[attr[0]] = attr[1]
          hash
        else
          hash.merge normalize_attributes(attr)
        end
      end
    end

    module Model

      def serialize(format, options)
        raise "Must specify :attributes option" unless options[:attributes]
        hash = self.to_serializable(options[:attributes])
        root = self.class.to_s.underscore
        if format == :xml
          hash.send("to_#{format}", :root => root)
        else
          {root => hash}.send("to_#{format}")
        end
      end

      def to_serializable(attributes)
        raise "Must specify attributes for #{self.inspect}.to_serializable" if attributes.nil?

        Serialize.normalize_attributes(attributes).inject({}) do |hash, (key, value)|
          hash[key.to_s] = attr_hash_value(self.send(key), value)
          hash
        end
      end

      protected

      def attr_hash_value(attr, sub_attributes)
        if attr.respond_to?(:to_serializable)
          attr.to_serializable(sub_attributes)
        else
          attr
        end
      end

    end

    module Array
      
      def serialize(format, options)
        raise "Not all elements respond to to_serializable" unless all? { |e| e.respond_to? :to_serializable }
        raise "Must specify :attributes option" unless options[:attributes]

        serialized = map { |e| e.to_serializable(options[:attributes]) }
        root = first.class.to_s.pluralize.underscore

        if format == :xml
          serialized.send("to_#{format}", :root => root)
        else
          {root => serialized}.send("to_#{format}")
        end
      end

      def to_serializable(attributes)
        if first.respond_to?(:to_serializable)
          attributes = Serialize.normalize_attributes(attributes)
          map { |e| e.to_serializable(attributes) }
        else
          self
        end
      end

    end
  end
end

class ActiveRecord::Base; include Resourceful::Serialize::Model; end
class Array; include Resourceful::Serialize::Array; end
