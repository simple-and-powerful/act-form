module ActForm
  module Merge
    extend ActiveSupport::Concern

    class_methods do
      def merge_attribute_set_from(other)
        other.attribute_set.each do |attr_name, arr|
          cast_type, options = arr
          attribute attr_name, cast_type, options
        end
      end
    end

  end
end
