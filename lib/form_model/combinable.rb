require 'active_support/concern'
require 'form_model/utils'

module FormModel
  module Combinable
    extend ActiveSupport::Concern

    included do
      class_attribute :_forms, instance_writer: false
      self._forms = []
    end

    class_methods do

      def combine(*forms)
        forms.each do |form_class|
          raise ArgumentError, 'Can not combine itself' if form_class == self

          next if self._forms.include?(form_class)

          self._forms << form_class

          self.merge(form_class.attribute_set)

          Utils.merge(self._validators, form_class._validators)

          method_name = form_class.model_name.singular
          define_method(method_name) { form_class.new(attributes) }
          form_class._validate_callbacks.each do |callback|
            filter = callback.filter
            if filter.is_a?(Symbol) || filter.is_a?(String)
              class_eval <<-RUBY, __FILE__, __LINE__ + 1
                def #{filter}
                  form = #{method_name}
                  form.send(:#{filter})
                  form.errors.details.each do |attr, _errors|
                    _errors.each { |err| errors.add(attr, err[:error]) }
                  end
                end
                private :#{filter}
              RUBY
            end
          end
          self._validate_callbacks.append *form_class._validate_callbacks
        end # forms.each
      end # combine

    end

  end
end
