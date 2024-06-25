require 'minitest/autorun'
require 'act_form'

BarAttributesV5 = %i[name age email gender other]
BarV5 = Struct.new('BarV5', *BarAttributesV5) do
  def save
    true
  end
end

class FullFunFormV5 < ActForm::Base
  params do
    required(:name).filled(:string)
    required(:email).value(:string, format?: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
    optional(:age).maybe(:integer)
    required(:address).hash do
      required(:street).filled(:string)
      required(:city).filled(:string)
      required(:zipcode).filled(:string)
    end
  end
end

class EmailFormV5 < ActForm::Base
  params do
    optional(:email).filled(:string).desc('邮箱')
  end

  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
end

class FooBarFormV5 < ActForm::Base
  params do
    required(:name).filled(:string).desc('名称')
  end
end

class FooBarFooFormV5 < ActForm::Base
  params do
    required(:name_with_default).filled(:string).default('DefaultName')
  end
end

class FooFormV5 < ActForm::Base
  params do
    required(:name)
    required(:age).filled(:integer)
  end

  validate :max_age

  def max_age
    errors.add(:age, :invalid) if age && age < 18
  end
end

class GlueFormV5 < ActForm::Base
  params do
    required(:gender)
  end

  combine EmailFormV5, FooFormV5
end

class ReusingGlueFormV5 < ActForm::Base
  params(FooFormV5) do
    required(:gender).filled
  end
end

class UserV5
  include ActiveModel::Model

  attr_accessor :name, :email, :phone

  def attributes
    { 'name' => name, 'email' => email, 'phone' => phone }
  end

  def save
    @saved = true
  end

  def saved?
    !!@saved
  end
end

class PhoneFormV5 < ActForm::Base
  params do
    optional(:phone)
  end

  validates_format_of :phone, with: /\A\d{11}\z/i
end

class UserFormV5 < ActForm::Base
  params do
    optional(:name)
  end

  combine EmailFormV5, PhoneFormV5
end

class CreateUserCommandV5 < ActForm::Command
  params do
    optional(:user)
  end

  combine UserFormV5

  def perform
    sync(user)
    user.save
    'saved'
  end
end

class ReassignCommandV5 < ActForm::Command
  params do
    optional(:content)
  end

  def perform
    self.content + 'bar'
  end
end

class SetupTestCommandV5 < ActForm::Command
  params do
    required(:content).filled(:string)
  end

  validate :set_value

  setup do
    raise 'empty' if content.nil?

    @setup_value = 123
    @value = 123
  end

  def perform
    [@setup_value, @value]
  end

  def set_value
    @value = 456
  end
end
