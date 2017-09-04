# StringlyEnums

Enums are stupid. Yes, let's store numbers in the database for things that should always be named,
to save a little space. Newsflash: String-based enums will unlikely become the performance bottleneck of
your system. Sorry, but it's true.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stringly_enums'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stringly_enums

## WARNING

We do nothing to sanitise inputs here, and we do a lot of `send`ing. Please don't
pass publicly-sourced strings to this project. You have been warned.

## Usage

Assuming you've created an indexed string field on your model, called status, any of the following will work:

```
  stringly_enum :status, [:first, :second, :third, :fourth], {... config ...}

  stringly_enum :status, {first: 0, second: 1}, {... config ...}

  stringly_enum :status do |status, config|
    # I've called the field status and the variable status for a reason -
    # it's quite self-documenting. Any grep that finds one of these lines
    # instantly knows what field and enum it refers to. Nice, huh?
    # The config below can be used in the config hashes above
    # Please note: currently, order matters - define your config first.
    config.scopes = false          # model.class.first
    config.boolean_getters = false # model.first?
    config.bang_setters = false    # model.first!
    config.save_after_bang = false # model.first! => self.status = :first; save
    config.accessor = false        # model.status = 1
    config.disable_all_metaprogramming!  # Turns off all of the above
    config.enable_all_metaprogramming!  # Turns on all of the above (the default)
    config.prefix_methods = true   # model.status_first?
    status.first int: 0, stored_as: '1st' # new values will be stored as 'first'
    status.second int: 1, stored_as: %w[2nd sec deuxieme]
    status.third int: 3, stored_as: 'therd'
    status.fourth # int will be 4, stored as 'fourth'
  end

```

The gem can also be configured site-wide, e.g. in an initializer, as follows:

```
  StringlyEnum.configure do |config| # ... config used as above
```

## V2 TODO

- An easy way to switch name / number (e.g. subject.status_int)
- A way to search by number (e.g. subject.where_status_above / where_status_below / where_status_between / where_status {|s| s.even? })


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/stringly_enums.
