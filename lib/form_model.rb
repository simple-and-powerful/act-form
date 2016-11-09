require 'form_model/version'
require 'form_model/model'
require 'form_model/runnable'

module FormModel
  class Base
    include Model
  end

  # Record must respond_to attributes method
  class Record < Base
    attr_reader :record
    def initialize(record, **attrs)
      @record = record
      @extract_attrs = @record.attributes.extract! *self.class.attribute_set.keys.map(&:to_s)
      super(@extract_attrs.merge(attrs))
    end

    def save
      if valid?
        sync(@record)
        @persisted = @record.save
      else
        false
      end
    end
  end

  class Command < Base
    include Runnable
    private_class_method :new
  end
end

require 'form_model/railtie' if defined?(Rails)
