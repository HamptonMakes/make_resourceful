require 'resourceful/builder'

module Resourceful
  module Serialize
    class XML < ActiveRecord::XmlSerializer
      Builder.register_format :xml, self

      def self.to_proc(options = {})
        return Proc.new { render :xml => Resourceful::Serialize::XML.new(current_object, options).to_s }
      end

      def initialize(model, options = {})
        options.merge! transform_attributes(options.delete(:attribute) || options.delete(:attributes))
        super(model, options)
      end

      private

      def transform_attributes(attributes)
        options = {}
        attributes = Array(attributes)
        
        options[:include] = Hash[*attributes.
          select { |attr| attr.is_a? Hash }.
          map { |attr, sub_attrs| [attr, fix_options(sub_attrs)] }.flatten]
        options[:only] = attributes.reject { |attr| attr.is_a? Hash}
        options
      end
    end
  end
end
