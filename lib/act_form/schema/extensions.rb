# frozen_string_literal: true

module ActForm
  module Schema
    module Extensions
      # Add defaults and descriptions to schema_dsl
      module DSLExtension
        def defaults
          @_defaults ||= {} # rubocop:disable Naming/MemoizedInstanceVariableName
        end

        def descriptions
          @_descriptions ||= {} # rubocop:disable Naming/MemoizedInstanceVariableName
        end
      end

      # Add default and desc macros
      module MacrosExtension
        def default(value)
          schema_dsl.defaults[name] = value
          self
        end

        def desc(value)
          schema_dsl.descriptions[name] = value
        end
      end
    end
  end
end
