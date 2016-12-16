# ActForm

ActForm is the gem that provide a simple way to create `form object` or `command object` or `service object`, it only depends on `activemodel >= 5` and provides few api.

## Usage

#### API - `attribute`

```ruby
class UserForm < ActForm::Base
  attribute :name, required: true
  attribute :age,  type: :integer
  attribute :address
  attribute :nickname, default: 'nick'
  attribute :desc, default: ->{ 'desc' }
end

form = UserForm.new(name: 'su', age: '18', address: 'somewhere')
form.name # => 'su'
form.age # => 18
form.address # => 'somewhere'
form.nickname # => 'nick'
form.desc # => 'desc'
# override default
form.nickname = 'hello'
form.nickname # => 'hello'

# required
form = UserForm.new(age: '18', address: 'somewhere')
form.valid? # => false
form.errors.full_messages # => ["Name require a value"]
```

#### Difference between `required` and `validates_presence_of`
`required` run before validation, it will cancel other validations if return false.

### form object

#### API - `valid?`
Compliant with the active model api
```ruby
class PhoneForm < ActForm::Base
  attribute :phone
  
  validates_format_of :phone, with: /\A\d{11}\z/i
end

form = PhoneForm.new
form.valid? # => false
form.errors.full_messages # => ["Phone is invalid"]

PhoneForm.new(phone: '12345678901').valid? # => true
```

#### API - `sync`
sync only copy attributes to target, will not trigger validate
```ruby
target = Class.new do
  attr_accessor :phone
end.new

form = PhoneForm.new(phone: '12345678901')
form.sync(target)
target.phone # => '12345678901'
```

#### API - `save`
sync to the target and call the save method when passed the validation
```ruby
target = Class.new do
  attr_accessor :phone
  attr_reader :saved
  
  def save
    @saved = true
  end
end.new

form = PhoneForm.new(phone: '12345678901')
form.save(target)
target.phone # => '12345678901'
target.saved # => true
form.persisted? # => true
```

#### API - `init_by`
`init_by` will copy attributes form target to the form, and set default target.
```ruby
target = Class.new do
  attr_accessor :phone
  attr_reader :saved
  
  def save
    @saved = true
  end
end.new

target.phone = '12345678901'

form = PhoneForm.new
form.init_by(target)
form.save # => true
target.saved # => true
```

#### API - `combine`
form can combine to other forms
```ruby
class PhoneForm < ActForm::Base
  attribute :phone
  validates_format_of :phone, with: /\A\d{11}\z/i
end

class EmailForm < ActForm::Base
  attribute :email
  
  validate :check_email
  
  def check_email
    errors.add(:email, :blank) if email.blank?
  end
end

class UserForm < ActForm::Base
  combine PhoneForm, EmailForm
end

class AdminForm < ActForm::Base
  combine PhoneForm
end

user_form = UserForm.new
user_form.valid?
user_form.errors.full_messages # => ["Phone is invalid", "Email can't be blank"]
UserForm.new(phone: '12345678901', email: '1').valid? # => true
admin_form = AdminForm.new
admin_form.valid?
admin_form.errors.full_messages # => ["Phone is invalid"]
AdminForm.new(phone: '12345678901').valid? # => true
```

### command/service object

Command object almost like form object. Command object can't init by `new`, and it has some new features.

#### API - `perform`, `run`, `success?`, `failure?`

command object must respond to `perform` method.

```ruby
class CreateUserCommand < ActForm::Command
  combine UserForm
  
  def perform
    # User.create(attributes)
  end
end

command = CreateUserCommand.run(phone: '12345678901')
if command.success?
  @user = command.result
  # do something...
else
  command.errors.full_messages # => ["Email can't be blank"]
  # do something...
end
```
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'act_form'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install act_form


## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/act_form. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

