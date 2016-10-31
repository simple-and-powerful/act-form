class RecordForm < FormModel::Base
  attr_reader :record
  def initialize(record, **attrs)
    @record = record
    @extract_attrs = @record.attributes.extract! *self.class.attribute_set.map(&:name).map(&:to_s)
    super(@extract_attrs.merge(attrs))
  end

  def sync
    super(@record)
  end

  def save
    if valid?
      sync
      @persisted = @record.save
    else
      false
    end
  end
end
