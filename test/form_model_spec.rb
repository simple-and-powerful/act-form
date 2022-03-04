require_relative './test_helper'

describe ActForm do

  def it_should_sync_to_bar_correctly(form_class, attributes)
    @form = form_class.new(attributes)
    @bar  = Bar.new
    @form.sync(@bar)
    BarAttributes.each do |attr|
      if (val = attributes[attr]) && form_class.attribute_set[attr.to_s]
        expect(@bar.public_send(attr)).must_equal val
      else
        expect(@bar.public_send(attr)).must_be_nil
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
      form = Class.new(ActForm::Base)
      expect((form.new.attributes == {})).must_equal true
    end

    it 'should return correct attributes if set attributes' do
      form = Class.new(ActForm::Base) do
        attribute :name
      end
      expect(form.new.name).must_be_nil
      expect(form.new(name: 'name').name).must_equal 'name'
    end

    it 'should return correct attributes if use alias method attr' do
      form = Class.new(ActForm::Base) do
        attr :name
      end
      expect(form.new.name).must_be_nil
      expect(form.new(name: 'name').name).must_equal 'name'
    end

    it 'should respect default option' do
      form = Class.new(ActForm::Base) do
        attribute :name, default: 'Default Name'
      end
      expect(form.new.name).must_equal 'Default Name'
      expect(form.new(name: 'name').name).must_equal 'name'
    end

    it 'should return false when pass value is false' do
      form = Class.new(ActForm::Base) do
        attribute :name
      end
      expect(form.new(name: false).name).must_equal false
    end

    it 'should type cast' do
      form = Class.new(ActForm::Base) do
        attribute :name, type: :string
        attribute :age,  type: :integer
        attribute :foo,  type: :boolean
      end
      expect(form.new(name: :abc).name).must_equal 'abc'
      expect(form.new(age: '1').age).must_equal 1
      expect(form.new(foo: 0).foo).must_equal false
    end

    it 'should respect required option' do
      foo = FooBarForm.new
      expect(foo.name).must_be_nil
      expect(foo.valid?).must_equal false
      expect(foo.errors.details[:name]).must_equal [{:error=>:required}]
    end

    it 'should respect required option and default' do
      foo = FooBarFooForm.new
      expect(foo.name_with_default).must_equal 'DefaultName'
      expect(foo.valid?).must_equal true
    end
  end

  it 'should return false without calling save method' do
    expect(EmailForm.new.persisted?).must_equal false
  end

  it 'should sync to target' do
    it_should_sync_to_bar_correctly(FooForm, {name: 'foo', age: 18, other: 'some'})
    expect(@bar.other).must_be_nil
  end

  describe '#save behavior' do
    it 'should save successful' do
      it_should_sync_to_bar_correctly(FooForm, {name: 'foo', age: 18})
      expect(@form.save(@bar)).must_equal true
      expect(@form.persisted?).must_equal true
    end
  end

  describe '#combine behavior' do
    it 'should raise error when combine itself' do
      klass = Class.new(ActForm::Base)
      expect(->{ klass.combine(klass) }).must_raise ArgumentError
    end

    it 'should combine attributes with forms' do
      it_should_sync_to_bar_correctly(GlueForm, {name: 'foo', age: 18, email: 'email', gender: 'm', other: 'some'})
      expect(@bar.other).must_be_nil
    end

    it 'should combine validators with forms' do
      expect(GlueForm.new.valid?).must_equal false
      expect(GlueForm.new(email: 'z@g.com', name: 'qin', age: 17).valid?).must_equal false
      expect(GlueForm.new(email: 'z@g.com', name: 'qin', age: 18).valid?).must_equal true
    end
  end

  describe 'RecordForm' do
    it 'should sync attributes form record' do
      attributes = {name: 'UserName', email: 'z@g.com', phone: '12345678909'}
      @user = User.new(attributes)
      @form = UserForm.new
      @form.init_by(@user)
      expect(@form.name).must_equal  attributes[:name]
      expect(@form.email).must_equal attributes[:email]
      expect(@form.phone).must_equal attributes[:phone]
    end

    it 'should raise exception if record not respond to attributes method' do
      @form = UserForm.new
      err = expect(-> { @form.record = Object.new }).must_raise ArgumentError
      expect(err.message).must_equal 'Record must respond to attributes method!'
    end

    it 'should raise exception if init by object not respond to attributes method' do
      @form = UserForm.new
      err = expect(-> { @form.init_by(Object.new) }).must_raise ArgumentError
      expect(err.message).must_equal 'Record must respond to attributes method!'
    end

    it 'should sync attributes form record and can override' do
      attributes = {name: 'UserName', email: 'z@g.com', phone: '12345678909'}
      @user = User.new(attributes)
      @form = UserForm.new
      @form.init_by(@user, name: 'NewName')
      expect(@form.name).must_equal 'NewName'
    end

    it 'should sync and save record' do
      attributes = {name: 'UserName', email: 'z@g.com', phone: '12345678909'}
      @user = User.new
      @form = UserForm.new
      @form.init_by(@user, attributes)
      expect(@form.save).must_equal true
      expect(@user.name).must_equal  attributes[:name]
      expect(@user.email).must_equal attributes[:email]
      expect(@user.phone).must_equal attributes[:phone]
    end

    it 'should not save record if form is invalid' do
      attributes = {name: 'UserName', email: 'z@g.com', phone: '12345678909'}
      @user = User.new(attributes)
      @form = UserForm.new
      @form.init_by(@user, email: 'z')
      expect(@form.save).must_equal false
      expect(@form.errors.messages[:email].present?).must_equal true
      expect(@user.name).must_equal attributes[:name]
      expect(@user.email).must_equal attributes[:email]
      expect(@user.phone).must_equal attributes[:phone]
    end
  end

  describe 'Command' do
    it 'should as runnable with run method' do
      @user = User.new
      command = CreateUserCommand.run(user: @user)
      expect(command.user).must_equal @user
      expect(command.success?).must_equal false
    end

    it 'should as runnable with run method successful' do
      @user = User.new
      command = CreateUserCommand.run(user: @user, name: 'Name', email: 'z@g.com', phone: '12345678909')
      expect(command.success?).must_equal true
      expect(command.result).must_equal 'saved'
      expect(@user.saved?).must_equal true
    end

    it 'should raise exception with run! method' do
      @user = User.new
      err = expect(-> { CreateUserCommand.run!(user: @user) }).must_raise ActForm::RunError
      expect(err.message).must_equal 'Verification failed'
    end

    it 'should reassign value correctly' do
      command = ReassignCommand.run(content: 'foo')
      expect(command.success?).must_equal true
      expect(command.result).must_equal 'foobar'
    end

  end
end
