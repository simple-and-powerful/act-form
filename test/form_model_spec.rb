require_relative './test_helper'

describe FormModel do

  def it_should_sync_to_bar_correctly(form_class, attributes)
    @form = form_class.new(attributes)
    @bar  = Bar.new
    @form.sync(@bar)
    BarAttributes.each do |attr|
      if (val = attributes[attr]) && form_class.attribute_set[attr.to_s]
        @bar.public_send(attr).must_equal val
      else
        @bar.public_send(attr).must_be_nil
      end
    end
  end

  describe 'test form model is compliant with the active model api' do
    include ActiveModel::Lint::Tests
    before do
      @model = EmailForm.new
    end
  end

  describe '#attribute behavior' do
    it 'should return empty hash if no attributes set' do
      form = Class.new(FormModel::Base)
      (form.new.attributes == {}).must_equal true
    end

    it 'should return correct attributes if set attributes' do
      form = Class.new(FormModel::Base) do
        attribute :name
      end
      form.new.name.must_be_nil
      form.new(name: 'name').name.must_equal 'name'
    end

    it 'should respect default option' do
      form = Class.new(FormModel::Base) do
        attribute :name, default: 'Default Name'
      end
      form.new.name.must_equal 'Default Name'
      form.new(name: 'name').name.must_equal 'name'
    end

    it 'should respect required option' do
      foo = FooBarForm.new
      foo.name.must_be_nil
      foo.valid?.must_equal false
      foo.errors.details[:name].must_equal [{:error=>:required}]
    end
  end

  it 'should return false without calling save method' do
    EmailForm.new.persisted?.must_equal false
  end

  it 'should sync to target' do
    it_should_sync_to_bar_correctly(FooForm, {name: 'foo', age: 18, other: 'some'})
    @bar.other.must_be_nil
  end

  describe '#save behavior' do
    it 'should save successful' do
      it_should_sync_to_bar_correctly(FooForm, {name: 'foo', age: 18})
      @form.save(@bar).must_equal true
      @form.persisted?.must_equal true
    end
  end

  describe '#combine behavior' do
    it 'should raise error when combine itself' do
      klass = Class.new(FormModel::Base)
      ->{ klass.combine(klass) }.must_raise ArgumentError
    end

    it 'should combine attributes with forms' do
      it_should_sync_to_bar_correctly(GlueForm, {name: 'foo', age: 18, email: 'email', gender: 'm', other: 'some'})
      @bar.other.must_be_nil
    end

    it 'should combine validators with forms' do
      GlueForm.new.valid?.must_equal false
      GlueForm.new(email: 'z@g.com', name: 'qin', age: 17).valid?.must_equal false
      GlueForm.new(email: 'z@g.com', name: 'qin', age: 18).valid?.must_equal true
    end
  end

  describe 'RecordForm' do
    it 'should sync attributes form record' do
      attributes = {name: 'UserName', email: 'z@g.com', phone: '12345678909'}
      @user = User.new(attributes)
      @form = UserForm.new(@user)
      @form.name.must_equal  attributes[:name]
      @form.email.must_equal attributes[:email]
      @form.phone.must_equal attributes[:phone]
    end

    it 'should sync attributes form record and can override' do
      attributes = {name: 'UserName', email: 'z@g.com', phone: '12345678909'}
      @user = User.new(attributes)
      @form = UserForm.new(@user, name: 'NewName')
      @form.name.must_equal 'NewName'
    end

    it 'should sync and save record' do
      attributes = {name: 'UserName', email: 'z@g.com', phone: '12345678909'}
      @user = User.new
      @form = UserForm.new(@user, attributes)
      @form.save.must_equal true
      @user.name.must_equal  attributes[:name]
      @user.email.must_equal attributes[:email]
      @user.phone.must_equal attributes[:phone]
    end

    it 'should not save record if form is invalid' do
      attributes = {name: 'UserName', email: 'z@g.com', phone: '12345678909'}
      @user = User.new(attributes)
      @form = UserForm.new(@user, email: 'z')
      @form.save.must_equal false
      @form.errors.messages[:email].present?.must_equal true
      @user.name.must_equal  attributes[:name]
      @user.email.must_equal attributes[:email]
      @user.phone.must_equal attributes[:phone]
    end
  end

  describe 'Command' do
    it 'should as runnable with run method' do
      @user = User.new
      command = CreateUserCommand.run(user: @user)
      command.user.must_equal @user
      command.success?.must_equal false
    end

    it 'should as runnable with run method successful' do
      @user = User.new
      command = CreateUserCommand.run(user: @user, name: 'Name', email: 'z@g.com', phone: '12345678909')
      command.success?.must_equal true
      command.result.must_equal 'saved'
      @user.saved?.must_equal true
    end
  end
end
