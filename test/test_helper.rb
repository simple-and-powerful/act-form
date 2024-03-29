require 'minitest/autorun'
require 'act_form'
require 'pry'

BarAttributes = %i(name age email gender other)
Bar = Struct.new('Bar', *BarAttributes) do
  def save
    true
  end
end

class EmailForm < ActForm::Base
  attribute :email

  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
end

class FooBarForm < ActForm::Base
  attribute :name, required: true
end

class FooBarFooForm < ActForm::Base
  attribute :name_with_default, required: true, default: 'DefaultName'
end

class FooForm < ActForm::Base
  attribute :name
  attribute :age, type: :integer

  validates_presence_of :name, :age

  validate :max_age

  def max_age
    errors.add(:age, :invalid) if age && age < 18
  end
end

class GlueForm < ActForm::Base
  attribute :gender

  combine EmailForm, FooForm
end

class User
  include ActiveModel::Model

  attr_accessor :name, :email, :phone

  def attributes
    {'name' => name, 'email' => email, 'phone' => phone}
  end

  def save
    @saved = true
  end

  def saved?
    !!@saved
  end
end

class PhoneForm < ActForm::Base
  attribute :phone

  validates_format_of :phone, with: /\A\d{11}\z/i
end

class UserForm < ActForm::Base
  attribute :name

  combine EmailForm, PhoneForm
end

class CreateUserCommand < ActForm::Command
  attribute :user

  combine UserForm

  def perform
    sync(user)
    user.save
    'saved'
  end
end

class ReassignCommand < ActForm::Command
  attribute :content

  def perform
    content = self.content + 'bar'
    content
  end
end

class SetupTestCommand < ActForm::Command
  attribute :content, required: true

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

