require_relative './test_helper_v5'

describe ActForm do
  def it_should_sync_to_bar_correctly(form_class, attributes)
    @form = form_class.new(attributes)
    @bar  = BarV5.new
    @form.sync(@bar)
    BarAttributesV5.each do |attr|
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
      @model = EmailFormV5.new
    end
  end

  describe '#params behavior' do
    it 'should act correct behavior' do
      form1 = FullFunFormV5.new
      expect(form1.valid?).must_equal false
      expect(form1.errors.details[:name]).must_equal [{ error: :required }]

      form2 = FullFunFormV5.new(
        name: 'Jane',
        email: 'jane',
        address: { street: 'Street 1', city: 'NYC', zipcode: '1234' }
      )
      expect(form2.valid?).must_equal false
      expect(form2.errors.details[:email]).must_equal [{ error: :invalid }]

      form3 = FullFunFormV5.new(
        name: 'Jane',
        email: 'z@g.com',
        address: { street: 'Street 1', city: 'NYC', zipcode: '1234' }
      )
      expect(form3.valid?).must_equal true
      expect(form3.name).must_equal 'Jane'
      expect(form3.email).must_equal 'z@g.com'
      expect(form3.address[:street]).must_equal 'Street 1'
      expect(form3.address[:city]).must_equal 'NYC'
      expect(form3.address[:zipcode]).must_equal '1234'

      form4 = FullFunFormV5.new(
        name: 'Jane',
        email: 'z@g.com',
        address: { street: 'Street 1', city: 'NYC' }
      )
      expect(form4.valid?).must_equal false
      expect(form4.errors.details[:address]).must_equal [{ error: :invalid }]
      expect(form4.errors.messages[:address]).must_equal ['zipcode is missing']
    end

    it 'should return correct attributes if set attributes' do
      form = Class.new(ActForm::Base) do
        params do
          optional :name
        end
      end
      expect(form.new.name).must_be_nil
      expect(form.new(name: 'name').name).must_equal 'name'
    end

    it 'should respect default option' do
      form = Class.new(ActForm::Base) do
        params do
          optional(:name).default('default name')
        end
      end
      expect(form.new.name).must_equal 'default name'
      expect(form.new(name: 'name').name).must_equal 'name'
    end

    it 'should return false when pass value is false' do
      form = Class.new(ActForm::Base) do
        params do
          optional :name
        end
      end
      expect(form.new(name: false).name).must_equal false
    end

    it 'should type cast' do
      form = Class.new(ActForm::Base) do
        params do
          optional(:name).value(:str?)
          optional(:age).value(:int?)
          optional(:foo).value(:bool?)
        end
      end
      expect(form.new(name: :abc).name).must_equal 'abc'
      expect(form.new(age: '1').age).must_equal 1
      expect(form.new(foo: 0).foo).must_equal false
    end

    it 'should respect required option' do
      foo = FooBarFormV5.new
      expect(foo.name).must_be_nil
      expect(foo.valid?).must_equal false
      expect(foo.errors.details[:name]).must_equal [{ error: :required }]
    end

    it 'should respect required option and default' do
      foo = FooBarFooFormV5.new
      expect(foo.name_with_default).must_equal 'DefaultName'
      expect(foo.valid?).must_equal true
    end

    it 'should respect parent schema' do
      form = ReusingGlueFormV5.new
      expect(form.valid?).must_equal false
      expect(form.errors.details[:age]).must_equal [{ error: :required }]
      expect(form.errors.details[:gender]).must_equal [{ error: :required }]

      form = ReusingGlueFormV5.new(age: 18, gender: 'male', name: 'foo')
      expect(form.valid?).must_equal true
    end
  end

  it 'should return false without calling save method' do
    expect(EmailFormV5.new.persisted?).must_equal false
  end

  it 'should sync to target' do
    it_should_sync_to_bar_correctly(FooFormV5, { name: 'foo', age: 18, other: 'some' })
    expect(@bar.other).must_be_nil
  end

  describe '#save behavior' do
    it 'should save successful' do
      it_should_sync_to_bar_correctly(FooFormV5, { name: 'foo', age: 18 })
      expect(@form.save(@bar)).must_equal true
      expect(@form.persisted?).must_equal true
    end
  end

  describe '#combine behavior' do
    it 'should raise error when combine itself' do
      klass = Class.new(ActForm::Base)
      expect(-> { klass.combine(klass) }).must_raise ArgumentError
    end

    it 'should combine attributes with forms' do
      it_should_sync_to_bar_correctly(GlueFormV5, { name: 'foo', age: 18, email: 'email', gender: 'm', other: 'some' })
      expect(@bar.other).must_be_nil
    end

    it 'should combine validators with forms' do
      expect(GlueFormV5.new.valid?).must_equal false
      expect(GlueFormV5.new(email: 'z@g.com', name: 'qin', age: 17, gender: 'f').valid?).must_equal false
      expect(GlueFormV5.new(email: 'z@g.com', name: 'qin', age: 18, gender: 'f').valid?).must_equal true
    end
  end

  describe 'RecordForm' do
    it 'should sync attributes form record' do
      attributes = { name: 'UserName', email: 'z@g.com', phone: '12345678909' }
      @user = UserV5.new(attributes)
      @form = UserFormV5.new
      @form.init_by(@user)
      expect(@form.name).must_equal  attributes[:name]
      expect(@form.email).must_equal attributes[:email]
      expect(@form.phone).must_equal attributes[:phone]
    end

    it 'should raise exception if record not respond to attributes method' do
      @form = UserFormV5.new
      err = expect(-> { @form.record = Object.new }).must_raise ArgumentError
      expect(err.message).must_equal 'Record must respond to attributes method!'
    end

    it 'should raise exception if init by object not respond to attributes method' do
      @form = UserFormV5.new
      err = expect(-> { @form.init_by(Object.new) }).must_raise ArgumentError
      expect(err.message).must_equal 'Record must respond to attributes method!'
    end

    it 'should sync attributes form record and can override' do
      attributes = { name: 'UserName', email: 'z@g.com', phone: '12345678909' }
      @user = UserV5.new(attributes)
      @form = UserFormV5.new
      @form.init_by(@user, name: 'NewName')
      expect(@form.name).must_equal 'NewName'
    end

    it 'should sync and save record' do
      attributes = { name: 'UserName', email: 'z@g.com', phone: '12345678909' }
      @user = UserV5.new
      @form = UserFormV5.new
      @form.init_by(@user, **attributes)
      expect(@form.save).must_equal true
      expect(@user.name).must_equal  attributes[:name]
      expect(@user.email).must_equal attributes[:email]
      expect(@user.phone).must_equal attributes[:phone]
    end

    it 'should not save record if form is invalid' do
      attributes = { name: 'UserName', email: 'z@g.com', phone: '12345678909' }
      @user = UserV5.new(attributes)
      @form = UserFormV5.new
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
      @user = UserV5.new
      command = CreateUserCommandV5.run(user: @user)
      expect(command.user).must_equal @user
      expect(command.success?).must_equal false
    end

    it 'should respect `setup` block with order' do
      command = SetupTestCommandV5.run(content: 'foobar')
      expect(command.content).must_equal 'foobar'
      expect(command.success?).must_equal true
      setup_value, value = command.result
      expect(setup_value).must_equal 123
      expect(value).must_equal 456
    end

    it 'should respect `setup` after required validation' do
      command = SetupTestCommandV5.run
      expect(command.success?).must_equal false
      expect(command.errors.details[:content]).must_equal [{ error: :required }]
    end

    it 'should as runnable with run method successful' do
      @user = UserV5.new
      command = CreateUserCommandV5.run(user: @user, name: 'Name', email: 'z@g.com', phone: '12345678909')
      expect(command.success?).must_equal true
      expect(command.result).must_equal 'saved'
      expect(@user.saved?).must_equal true
    end

    it 'should raise exception with run! method' do
      @user = UserV5.new
      err = expect(-> { CreateUserCommandV5.run!(user: @user) }).must_raise ActForm::RunError
      expect(err.message).must_equal 'Verification failed'
    end

    it 'should reassign value correctly' do
      command = ReassignCommandV5.run(content: 'foo')
      expect(command.success?).must_equal true
      expect(command.result).must_equal 'foobar'
    end
  end
end
