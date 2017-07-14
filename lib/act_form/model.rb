require 'active_model'
require 'act_form/attributes'
require 'act_form/merge'
require 'act_form/combinable'

module ActForm
  module Model
    extend ActiveSupport::Concern
    include ActiveModel::Model
    include Attributes
    include Merge

    included do
      set_callback :validate, :before, :validate_required_attributes
    end

    def initialize(attrs={})
      super attrs.select { |k, _| respond_to?("#{k}=") }
    end

    def record=(record)
      if record.respond_to?(:attributes)
        @record = record
      else
        raise ArgumentError, 'Record must respond to attributes method!'
      end
    end

    # Record must respond_to attributes method
    def init_by(record, **attrs)
      record  = record
      _attrs  = @record.attributes.extract! *self.class.attribute_set.keys.map(&:to_s)
      assign_attributes _attrs.merge(attrs)
    end

    def sync(target)
      self.class.attribute_set.keys.each do |attr|
        next unless target.respond_to?(attr)
        target.public_send "#{attr}=", public_send(attr)
      end
    end

    def save(target = nil)
      target ||= @record
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
