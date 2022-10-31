# 0.4.2
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

# 0.4.1
* fix issue#5

# 0.4.0
* update bundler dependency to `2.1.x`
* update spec syntex
* support rails `6.0`
* add shortcut alias method `attr` for `attribute`
* fix issue#2 
