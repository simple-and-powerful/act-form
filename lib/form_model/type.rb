require 'active_model/type'

module FormModel
  module Type
    class Object < ActiveModel::Type::Value
      def type
        :object
      end
    end
  end
end

ActiveModel::Type.register(:object, FormModel::Type::Object)
