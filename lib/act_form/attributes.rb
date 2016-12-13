require 'act_form/type'

module ActForm
  module Attributes
    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_set, instance_accessor: false
      self.attribute_set = {}
    end

    def attributes
      @attributes || {}
    end

    private

    def get_default(default, default_provided)
      return if default == default_provided
      default.respond_to?(:call) ? default.call : default
    end

    module ClassMethods
      # attribute :name, type: :string
      #   or
      # attribute :name, :string, required: true
      def attribute(name, cast_type = :object, **options)
        name = name.to_s
        cast_type = options[:type] || cast_type
        self.attribute_set = attribute_set.merge(name => [cast_type, options])

        define_reader_method name, **options.slice(:default)
        define_writer_method name, cast_type

        name
      end

      def define_reader_method(name, default: NO_DEFAULT_PROVIDED)
        define_method(name) { attributes[name] || get_default(default, NO_DEFAULT_PROVIDED) }
      end

      def define_writer_method(name, cast_type)
        define_method("#{name}=") do |value|
          _value = ActiveModel::Type.lookup(cast_type).deserialize(value)
          @attributes = attributes.merge({name => _value})
          _value
        end
      end

      private

      NO_DEFAULT_PROVIDED = Object.new
      private_constant :NO_DEFAULT_PROVIDED

    end # class_methods
  end
end
