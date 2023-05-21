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
      say("Maybe look into the above thing ...", :warning)
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

puts("IncludeProcessor#run Result: #{result.inspect}")
Result: "The Result!"
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
      Say.("Maybe look into the above thing ...", :warning)
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

puts("DirectAccessProcessor#run Result: #{result.inspect}")
Result: "The Result!"
```

## Namespace Pollution

If you choose to `include Say` then your class will gain the following instance methods:
- `say`
- `say_with_block`
- `say_result`
- `say_footer`
- `say_banner`
- `say_message`
- `say_header`

... though you probably really only need one: `say`.

```ruby
class WithInclude
  include Say
end

class WithoutInclude end

Say.("Class methods added by `include Say`: #{WithInclude.methods - WithoutInclude.methods}", :info)
-- Class methods added by `include Say`: []

Say.("Instance methods added by `include Say`: #{WithInclude.new.methods - WithoutInclude.new.methods}", :info)
-- Instance methods added by `include Say`: [:say, :say_with_block, :say_result, :say_footer, :say_banner, :say_message, :say_header]
```

## Integration

### iTerm2
The standardized nature of Say's logging methods lends itself well to highlighting output types using iTerm2's Text Highlighting Triggers. To set this up, go to Settings for iTerm2 -> Profiles -> Advanced -> Triggers section: "Edit" Button.

![iTerm2 Triggers Setup](/screenshots/iterm2-triggers.png?raw=true "iTerm2 Triggers Setup")

For more help, see [iTerm's documentation on Triggers](https://iterm2.com/triggers.html).

The regular expressions and HEX codes used in the screenshot are:

```ruby
->          # Background HEX: #54a76c
>>          # Background HEX: #ff8e00     (Optional) Text HEX: #4c4c4c
--          # Background HEX: #666666
!¡          # Background HEX: #fff808     (Optional) Text HEX: #000000
\*{2,}.*    # Background HEX: #ff0000
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. Or, run `rake` to run the tests plus linters. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, bump latest ruby target versions, etc., with `rake bump`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Documentation

[YARD documentation](https://yardoc.org/index.html) can be generated and viewed live:
1. Install YARD: `gem install yard`
2. Run the YARD server: `yard server --reload`
3. Open the live documentation site: `open http://localhost:8808`

While the YARD server is running, documentation in the live site will be auto-updated on save.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pdobb/say. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pdobb/say/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Say project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pdobb/say/blob/master/CODE_OF_CONDUCT.md).
