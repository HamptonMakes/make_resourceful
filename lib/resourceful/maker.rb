require 'resourceful/builder'
require 'resourceful/base'

module Resourceful
  module Maker
    def self.extended(base)
      base.write_inheritable_attribute :resourceful_callbacks,    {}
      base.write_inheritable_attribute :resourceful_responses,    {}
      base.write_inheritable_attribute :resourceful_associations, {}
      base.write_inheritable_attribute :parents,                  []
    end

    def make_resourceful(*args, &block)
      include Resourceful::Base

      builder = Resourceful::Builder.new
      Resourceful::Base.made_resourceful.each { |proc| builder.instance_eval(&proc) }
      builder.instance_eval(&block)
      builder.apply(self)

      add_helpers
    end

    private

    def add_helpers
      helper_method(:object_path, :objects_path, :new_object_path, :edit_object_path,
                    :current_objects, :current_object, :current_model, :current_model_name,
                    :namespaces, :instance_variable_name, :parents, :parent_model_names,
                    :parent_objects)
    end
  end
end
