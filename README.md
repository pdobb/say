# Say

[![Gem Version](https://img.shields.io/github/v/release/pdobb/say)](https://img.shields.io/github/v/release/pdobb/say)
[![CI Actions](https://github.com/pdobb/say/actions/workflows/ci.yml/badge.svg)](https://github.com/pdobb/say/actions)

Say gives you the API and the output style you already know and love from [ActiveRecord::Migration#say](https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say)... anywhere! Plus a few extra goodies for long-running processes like incremental progress indicators and remaining time estimation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "say", github: "pdobb/say"
```

And then execute:

```bash
bundle
```

## Usage

### `include Say`

Typical usage is to `include Say` in your object and then call the `say` method as needed.

When called with a block, `say` will output both Start and Finish banners, while still returning the result of the block.
When called without a block, `say` will output a string of the specified type (defaults to `:success`).

```ruby
require "say"

class IncludeProcessor
  include Say

  def run
    say("IncludeProcessor") {
      say("Successfully did the thing!")
      say
      say("Debug details about this ...", :debug)
      say("Info about stuff ...", :info)
      say("Maybe look into this thing ...", :warn)
      say("Failed to do a thing ...", :error)

      "The Result!"
    }
  end
end

result = IncludeProcessor.new.run
= IncludeProcessor =============================================================
 -> Successfully did the thing!
 ...
 >> Debug details about this ...
 -- Info about stuff ...
 !¡ Maybe look into this thing ...
 !¡ Maybe look into the above thing ...
 ** Failed to do a thing ...
= Done (0.0000s) ===============================================================

result  # => "The Result!"
```

### `Say.<method>`

For quick-access usage, you can just call `Say.<method>` without including `Say`.

```ruby
require "say"

class DirectAccessProcessor
  def run
    Say.("DirectAccessProcessor") {
      Say.("Successfully did the thing!")
      Say.() # Or: Say.call
      Say.("Debug details about this ...", :debug)
      Say.("Info about stuff ...", :info)
      Say.("Maybe look into this thing ...", :warn)
      Say.("Failed to do a thing ...", :error)

      "The Result!"
    }
  end
end

result = DirectAccessProcessor.new.run
= DirectAccessProcessor ========================================================
 -> Successfully did the thing!
 ...
 >> Debug details about this ...
 -- Info about stuff ...
 !¡ Maybe look into this thing ...
 !¡ Maybe look into the above thing ...
 ** Failed to do a thing ...
= Done (0.0000s) ===============================================================

result  # => "The Result!"
```

### Say Types
When calling `Say.call(<message>, <type>)`, the available types and output representations are:

- `:debug`   -> `" >> "`
- `:error`   -> `" ** "`
- `:info`    -> `" -- "`
- `:success` -> `" -> "`
- `:warn`    -> `" !¡ "`

For example:

```ruby
Say.("TEST", :debug)   # => " >> TEST"
Say.("TEST", :error)   # => " ** TEST"
Say.("TEST", :info)    # => " -- TEST"
Say.("TEST", :success) # => " -> TEST"
Say.("TEST", :warn)    # => " !¡ TEST"
```

### Progress Tracking

Use `Say.progress` to track long-running processing loops on a given interval. Set the interval to receive `say` updates only during on-interval ticks through the loop. The default interval is `1`, meaning every loop is considered on-interval.

#### Simple
```ruby
# The default interval is 1.
Say.progress do |interval|
  3.times.with_index do |index|
    # Increment the interval's internal index by 1.
    interval.update

    # Only "say" for on-interval ticks through the loop.
    interval.say("Index: #{index}", :debug)
  end
end
= Start (i=0) ==================================================================
 >> Index: 0
 >> Index: 1
 >> Index: 2
= Done (0.0000s) ===============================================================
```

#### Advanced
```ruby
Say.progress("Progress Tracking Test", interval: 3) do |interval|
  0.upto(6) do |index|
    # Set the interval's internal index to the current index. This may be safer.
    interval.update(index)

    # Only "say" for on-interval ticks through the loop.
    interval.say("Before Update Interval. Index: #{index}", :debug)
    # Optionally use a block to time a segment.
    interval.say("Progress Interval Block.") do
      sleep(0.025) # Do the work here.

      # Always "say", regardless of interval in the usual way; with `Say.call`.
      Say.("Interval-Agnostic Update. Index: #{index}", :info)
    end
    interval.say("After Update Interval. Index: #{index}", :debug)
  end
end
= Progress Tracking Test (i=0) =================================================
 -- Interval-Agnostic Update. Index: 0
 -- Interval-Agnostic Update. Index: 1
 -- Interval-Agnostic Update. Index: 2
 >> Before Update Interval. Index: 3
= Progress Interval Block. (i=3) ===============================================
 -- Interval-Agnostic Update. Index: 3
= Done (0.0261s) ===============================================================

 >> After Update Interval. Index: 3
 -- Interval-Agnostic Update. Index: 4
 -- Interval-Agnostic Update. Index: 5
 >> Before Update Interval. Index: 6
= Progress Interval Block. (i=6) ===============================================
 -- Interval-Agnostic Update. Index: 6
= Done (0.0261s) ===============================================================

 >> After Update Interval. Index: 6
= Done (0.1831s) ===============================================================
```

## Namespace Pollution

If you choose to `include Say` then your class will gain the following instance methods:
- `say`
- `say_banner`
- `say_footer`
- `say_header`
- `say_message`
- `say_progress`
- `say_result`
- `say_with_block`

... though you probably really only need one: `say`.

```ruby
class WithInclude
  include Say
end

class WithoutInclude
end

added_class_methods = WithInclude.methods - WithoutInclude.methods
Say.("Class methods added by `include Say`: #{added_class_methods}")
 -- Class methods added by `include Say`: []

added_instance_methods = (WithInclude.new.methods - WithoutInclude.new.methods).sort!
Say.("Instance methods added by `include Say`: #{added_instance_methods}")
 -- Instance methods added by `include Say`: [:say, :say_banner, :say_footer, :say_header, :say_message, :say_progress, :say_result, :say_with_block]
```

## Integration

### iTerm2
The standardized nature of Say's logging methods lends itself well to highlighting output types using iTerm2's Text Highlighting Triggers. To set this up, go to Settings for iTerm2 -> Profiles -> Advanced -> Triggers section: "Edit" Button.

![iTerm2 Triggers Setup](/screenshots/iterm2-triggers.png?raw=true "iTerm2 Triggers Setup")

For more help, see [iTerm's documentation on Triggers](https://iterm2.com/triggers.html).

The regular expressions and HEX codes used in the screenshot are:

```ruby
(?<=^ )->(?= )  # Text HEX: #0ae400  Background HEX: transparent
(?<=^ )>>(?= )  # Text HEX: #ff6500  Background HEX: transparent
(?<=^ )--(?= )  # Text HEX: #ffffff  Background HEX: #666666
(?<=^ )!¡(?= )  # Text HEX: #ffff00  Background HEX: transparent
.*\*{2,}.*      # Text HEX: #ffffff  Background HEX: #ff0000
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. Or, run `rake` to run the tests plus linters. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, bump the latest ruby target versions etc. with `rake bump`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and attempt to push the `.gem` file to [rubygems.org](https://rubygems.org) -- NOTE: this gem doesn't live on rubygems.org because of a naming conflict, so the upload attempt can be aborted when 2FA is requested.

### Documentation

[YARD documentation](https://yardoc.org/index.html) can be generated and viewed live:
1. Install YARD: `gem install yard`
2. Run the YARD server: `yard server --reload`
3. Open the live documentation site: `open http://localhost:8808`

While the YARD server is running, documentation in the live site will be auto-updated on source code save (and site reload).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pdobb/say. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pdobb/say/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Say project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pdobb/say/blob/master/CODE_OF_CONDUCT.md).
