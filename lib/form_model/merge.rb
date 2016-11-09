module FormModel
  module Merge
    extend ActiveSupport::Concern

    class_methods do
      def merge(other)
        other.attribute_set.each do |attr_name, attr_arr|
          cast_type, options = attr_arr
          attribute attr_name, cast_type, options
        end
      end
    end

  end
end
