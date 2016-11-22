require 'active_support/concern'
require 'form_model/utils'

module FormModel
  module Combinable
    extend ActiveSupport::Concern

    included do
      class_attribute :_forms, instance_writer: false
      self._forms = []
    end

    def valid?(context = nil)
      super
      combined_forms_valid?(context)
      errors.empty?
    end

    def combined_forms_valid?(context)
      return if _forms.empty?
      _forms.each do |form_class|
        form = form_class.new(attributes)
        form.valid?(context)
        form.errors.details.each do |attr_name, arr|
          arr.each do |error|
            next if error[:error] == :required
            errors.add(attr_name, error[:error])
          end
        end
      end
    end

    class_methods do

      def combine(*forms)
        forms.each do |form_class|
          raise ArgumentError, "can't combine itself" if form_class == self

          next if self._forms.include?(form_class)

          self.merge_attribute_set_from(form_class)
          self._forms << form_class
        end
      end

    end

  end
end
