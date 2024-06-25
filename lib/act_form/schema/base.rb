# frozen_string_literal: true

module ActForm
  module Schema
    class Base # rubocop:disable Style/Documentation
      attr_reader :ins

      def initialize(*parents, &block)
        parent_arr = parents.map(&:contract)
        @ins = ::Dry::Schema.Params(parent: parent_arr, &block)
        @json = @ins.json_schema(loose: true)
        @defaults = @ins.schema_dsl.defaults
        @descriptions = @ins.schema_dsl.descriptions
      end

      def each # rubocop:disable Metrics/AbcSize
        @ins.key_map.each do |key|
          name = key.name.to_sym
          opts = {
            required: @json[:required].include?(key.name)
          }
          opts[:default] = @defaults[name] if @defaults.key?(name)
          t = @json[:properties].dig(name, :type)
          t = if t.is_a?(Array)
                :object
              else
                t ? t.to_sym : :object
              end
          opts[:type] = t
          yield name, opts
        end
      end

      def validate(attrs)
        _attrs = {}.merge!(attrs)
        _attrs.merge!(@defaults)
        @ins.call(_attrs)
      end
    end
  end
end
