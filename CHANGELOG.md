# 0.5.0
* [Feature] issue#7 add more attribute type
* [Feature] issue#3 add `combine` DEPRECATION

With the power of `dry-schema`, ActForm now can support all the features of `dry-schema`, like:

```ruby
class UserForm < ActForm::Base
  params do
    required(:name).filled.desc('Name')
    optional(:age).value(:integer).desc('Age')
    optional(:address).desc('Address')
    optional(:nickname).default('nick').desc('Nick')
    # below will support in the future
    # attribute :desc, default: ->{ 'desc' }
  end
end
```

Add we can integrate with `grape` easyly.

```ruby
module WorkWithGrapeSpec
  class API < Grape::API
    format :json

    contract UserForm.contract
    get '/foo' do
      'hello world'
    end

    contract FooService.contract do
      required(:desc).filled
    end
    get '/bar' do
      'hello world'
    end
  end
end
```

# 0.4.4
* [Fix] fix `setup` run before `required` validation

# 0.4.3
* [Feature] issue#6 add `setup` method
```ruby
class SomeCommand < Act::Command
  # use setup to pre-inialize some actions.
  setup do
    @ins = 1
  end

  def perform
    @ins # use @ins
  end
end
```

# 0.4.2 [yank]

# 0.4.1
* fix issue#5

# 0.4.0
* update bundler dependency to `2.1.x`
* update spec syntex
* support rails `6.0`
* add shortcut alias method `attr` for `attribute`
* fix issue#2 
