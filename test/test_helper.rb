require 'minitest/autorun'
require 'form_model'
require 'pry'

BarAttributes = %i(name age email gender other)
Bar = Struct.new('Bar', *BarAttributes) do
  def save
    true
  end
end

class EmailForm < FormModel::Base
  attribute :email

  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
end

class FooForm < FormModel::Base
  attribute :name
  attribute :age, type: :integer

  validates_presence_of :name, :age

  validate :max_age

  def max_age
    errors.add(:age, :invalid) if age && age < 18
  end
end

class GlueForm < FormModel::Base
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

class PhoneForm < FormModel::Base
  attribute :phone

  validates_format_of :phone, with: /\A\d{11}\z/i
end

class UserForm < FormModel::RecordForm
  attribute :name

  combine EmailForm, PhoneForm
end

class CreateUserCommand < FormModel::Command
  attribute :user

  combine UserForm

  def perform
    sync(user)
    user.save
    'saved'
  end
end

