require 'active_support/core_ext/object/deep_dup'
require 'active_model'
# require 'virtus'
require 'form_model/attributes'
require 'form_model/combinable'

module FormModel
  module Model
    extend ActiveSupport::Concern
    include ActiveModel::Model
    include FormModel::Attributes

    def sync(target)
      self.class.attribute_set.keys.each do |attr|
        target.public_send("#{attr}=", public_send(attr)) if target.respond_to?(attr)
      end
    end

    def save(target)
      if valid?
        sync(target)
        @persisted = target.save
      else
        false
      end
    end

    def persisted?
      !!@persisted
    end

    class_methods do
      private

      def inherited(child_class)
        child_class._validators = self._validators.deep_dup
        child_class._validate_callbacks = self._validate_callbacks.deep_dup
        child_class.include Combinable
        super
      end
    end # class_methods
  end
end
