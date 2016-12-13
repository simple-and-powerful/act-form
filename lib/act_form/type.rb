require 'active_model/type'

module ActForm
  module Type
    class Object < ActiveModel::Type::Value
      def type
        :object
      end
    end
  end
end

ActiveModel::Type.register(:object, ActForm::Type::Object)
