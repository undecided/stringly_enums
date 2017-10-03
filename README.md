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
    # Please note: currently, in block-based config, order matters -
    # if you don't define your config first, it won't be seen.
    config.scopes = true            # model.class.first

    config.allowable_values_as = "%s_values"     # any value we expect the database to contain
                                                 # will be available from this class method,
                                                 # e.g. MyModel.status_values
                                                 #      => 'first', '1st', 'second', etc
                                                 # useful in validations - false to disable
    config.available_options_as = "%s_options"   # any value the field should be set to
                                                 # will be available from this class method,
                                                 # e.g. MyModel.status_options
                                                 #      => :first, :second, :third, etc
                                                 # useful in drop-downs - false to disable
    config.available_mappings_as = "%s_mappings" # the {integer => option} mappings
                                                 # will be available from this class method,
                                                 # e.g. MyModel.status_mappings
                                                 #      => {0 => :first, 1 => :second, etc}

    config.boolean_getters = true   # model.first?
    config.bang_setters = true      # model.first!
    config.save_after_bang = true   # model.first! => self.status = :first; save
    config.accessor = true          # model.status = 1
                                    # modl.status #=> :first (instead of 'first')
                                    # you will definitely want this if multi=true
    config.disable_all_metaprogramming! # Turns off all of the above
    config.enable_all_metaprogramming!  # Turns on all of the above (the default)
    config.multi = true              # model.status = [1, :second]
    config.prefix_methods = true     # model.status_first?
    status.first int: 0, stored_as: '1st' # new values will be stored as 'first'
    status.second int: 1, stored_as: ['2nd', 'sec' 'le deuxieme']
    status.third int: 3, stored_as: 'therd'
    status.fourth # int will be 4, stored as 'fourth'
  end

```

## Migrating to multi mode

Gotchas:
- bang_setters append, they do not replace.
- Trying to use multi mode and config.bang_setters requires config.accessor to be true (default). Otherwise, here be dragons.

## V2 TODO
- assuming string storage, always return symbols
- An easy way to switch name / number (e.g. subject.status_int)
- A way to search by number (e.g. subject.where_status_above / where_status_below / where_status_between / where_status {|s| s.even? })
- The gem should be configurable site-wide, e.g. in an initializer, as follows:

```
StringlyEnum.configure do |config| # ... config used as above
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/stringly_enums.
