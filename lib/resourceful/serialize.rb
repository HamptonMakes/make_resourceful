require 'resourceful/builder'

module Resourceful
  module Serialize
    module Model

      def serialize(format, options)
        raise "Must specify :attributes option" unless options[:attributes]
        hash = self.to_resourceful_hash(options[:attributes])
        root = self.class.to_s.underscore
        if format == :xml
          hash.send("to_#{format}", :root => root)
        else
          {root => hash}.send("to_#{format}")
        end
      end

      def to_resourceful_hash(attributes)
        raise "Must specify attributes for #{self.inspect}.to_resourceful_hash" if attributes.nil?

        normalize_attributes(attributes).inject({}) do |hash, (key, value)|
          hash[key.to_s] = attr_hash_value(self.send(key), value)
          hash
        end
      end

      protected

      def attr_hash_value(attr, sub_attributes)
        if attr.responds_to?(:to_resourceful_hash)
          attr.to_resourceful_hash(sub_attributes)
        else
          attr
        end
      end

      private
      
      def normalize_attributes(attributes)
        return nil if attributes.nil?
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

    end

    module Array
      
      def serialize(format, options)
        raise "Not all elements respond to to_resourceful_hash" unless all? { |e| e.respond_to? :to_resourceful_hash }

        serialized = map { |e| e.to_resourceful_hash(options[:attributes]) }
        root = first.class.to_s.pluralize.underscore

        if format == :xml
          serialized.send("to_#{format}", :root => root)
        else
          {root => serialized}.send("to_#{format}")
        end
      end

      def to_resourceful_hash(attributes)
        if first.responds_to?(:to_resourceful_hash)
          map { |e| e.to_resourceful_hash(attributes) }
        else
          self
        end
      end

    end
  end
end

class ActiveRecord::Base; include Resourceful::Serialize::Model; end
class Array; include Resourceful::Serialize::Array; end
