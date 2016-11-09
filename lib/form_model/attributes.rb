require 'form_model/type'

module FormModel
  module Attributes
    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_set, instance_accessor: false
      self.attribute_set = {}
    end

    def attributes
      self.class.attribute_set.keys.map do |attr|
        [attr, public_send(attr)]
      end.to_h
    end

    module ClassMethods
      # attribute :name, type: :string
      # or
      # attribute :name, :string
      def attribute(name, cast_type = :object, **options)
        name = name.to_s
        self.attribute_set = attribute_set.merge(name => [(options[:type] || cast_type), options])

        define_attribute_reader(name, options)
        define_attribute_writer(name, cast_type, options)
      end

      def merge(new_attribute_set)
        new_attribute_set.each do |attr_name, attr_arr|
          cast_type, options = attr_arr
          attribute attr_name, cast_type, options
        end
      end

      def define_attribute_reader(name, options)
        provided_default = options.fetch(:default) { NO_DEFAULT_PROVIDED }
        define_method name do
          return instance_variable_get("@#{name}") if instance_variable_defined?("@#{name}")
          return if provided_default == NO_DEFAULT_PROVIDED
          provided_default.respond_to?(:call) && provided_default.call || provided_default
        end
      end

      def define_attribute_writer(name, cast_type, options)
        define_method "#{name}=" do |val|
          deserialized_value = ActiveModel::Type.lookup(cast_type).deserialize(val)
          instance_variable_set("@#{name}", deserialized_value)
        end
      end

      private

      NO_DEFAULT_PROVIDED = Object.new
      private_constant :NO_DEFAULT_PROVIDED

    end # class_methods
  end
end
