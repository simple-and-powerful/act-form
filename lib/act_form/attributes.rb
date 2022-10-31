# frozen_string_literal: true

require 'act_form/type'

module ActForm
  module Attributes # rubocop:disable Style/Documentation
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

    module ClassMethods # rubocop:disable Style/Documentation
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
      alias attr attribute

      def define_reader_method(name, default: NO_DEFAULT_PROVIDED)
        define_method(name) do
          if attributes.key?(name)
            attributes[name]
          else
            get_default(default, NO_DEFAULT_PROVIDED)
          end
        end
      end

      def define_writer_method(name, cast_type)
        define_method("#{name}=") do |value|
          val = ActiveModel::Type.lookup(cast_type).deserialize(value)
          @attributes = attributes.merge({ name => val })
          val
        end
      end

      NO_DEFAULT_PROVIDED = Object.new
      private_constant :NO_DEFAULT_PROVIDED
    end
  end
end
