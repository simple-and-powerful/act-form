require 'active_support/core_ext/object/deep_dup'
require 'active_model'
require 'form_model/attributes'
require 'form_model/merge'
require 'form_model/combinable'

module FormModel
  module Model
    extend ActiveSupport::Concern
    include ActiveModel::Model
    include Attributes
    include Merge

    included do
      set_callback :validate, :before, :validate_required_attributes
    end

    def initialize(attributes={})
      super attributes.select { |k, _| respond_to?("#{k}=") }
    end

    def sync(target)
      self.class.attribute_set.keys.each do |attr|
        next unless target.respond_to?(attr)
        target.public_send "#{attr}=", public_send(attr)
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

    private

    def validate_required_attributes
      self.class.attribute_set.each do |attr_name, arr|
        _, options = arr
        next if !options[:required]
        if attributes[attr_name].nil?
          errors.add(attr_name, :required)
        end
      end
      throw(:abort) unless errors.empty?
    end

    class_methods do
      private
      def inherited(child_class)
        child_class.include Combinable
        super
      end
    end # class_methods
  end
end
