# frozen_string_literal: true

require 'active_model/type'

module ActForm
  module Type
    # Add +Object+ type
    class Object < ActiveModel::Type::Value
      def type
        :object
      end
    end
  end
end

ActiveModel::Type.register(:object, ActForm::Type::Object)
