# frozen_string_literal: true

module ActForm
  module Schema # rubocop:disable Style/Documentation
    extend ActiveSupport::Concern

    included do
      class_attribute :_schema, instance_accessor: false
      self._schema = nil
    end

    module ClassMethods # rubocop:disable Style/Documentation
      def contract
        self._schema.ins
      end

      def params(*parents, &block)
        self._schema = Base.new(*parents, &block)
        self._schema.each { |k, opts| self.attribute(k, **opts) }
      end
    end
  end
end
