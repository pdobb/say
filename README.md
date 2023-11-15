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

## Compatibility

Tested MRI Ruby Versions:
* 2.7
* 3.0
* 3.1
* 3.2

Say has no other dependencies.


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
 ** Failed to do a thing ...
= Done (0.0001s) ===============================================================

result  # => "The Result!"
```

### `Say.<method>`

For quick-access usage, you can just call `Say.<method>` without needing to `include Say`.

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
 ** Failed to do a thing ...
= Done (0.0001s) ===============================================================

result  # => "The Result!"
```

### Say Types
When using `Say.(<message>, <type>)`, the available types and output representations are:

- `:debug`   -> `" >> "`
- `:error`   -> `" ** "`
- `:info`    -> `" -- "`
- `:success` -> `" -> "`
- `:warn`    -> `" !¡ "`

```ruby
Say.("TEST", :debug)   # => " >> TEST"
Say.("TEST", :error)   # => " ** TEST"
Say.("TEST", :info)    # => " -- TEST"
Say.("TEST", :success) # => " -> TEST"
Say.("TEST", :warn)    # => " !¡ TEST"
```

The default type is `:success`.

```ruby
Say.("TEST")  # => " -> TEST"
```

### `Say.<type>` Methods
Single-argument alternatives for each of the `<type>` calls in the previous section:

```ruby
Say.debug("TEST")   # => " >> TEST"
Say.error("TEST")   # => " ** TEST"
Say.info("TEST")    # => " -- TEST"
Say.success("TEST") # => " -> TEST"
Say.warn("TEST")    # => " !¡ TEST"
```

### `Say.section`

Use `Say.section` for 3-line banners to really visually split up your output into major sections.

```ruby
Say.section
================================================================================
================================================================================
================================================================================

Say.section("TEST")
================================================================================
= TEST =========================================================================
================================================================================

Say.section("TEST", columns: 0)
========
= TEST =
========
```

### Justifiers
The various banner-producing methods also support left/center/right justification. Just pass in e.g. `justify: :left`, `justify: :center`, or `justify: :right`. The default, if nothing is supplied, is `justify: :left`.

```ruby

# Block

Say.("Hello, World!") { Say.("Huzzah!") }
= Hello, World! ================================================================
 -> Huzzah!
= Done (0.0000s) ===============================================================

Say.("Hello, World!", justify: :left) { Say.("Huzzah!") }
= Hello, World! ================================================================
 -> Huzzah!
= Done (0.0000s) ===============================================================

Say.("Hello, World!", justify: :center) { Say.("Huzzah!") }
================================= Hello, World! ================================
 -> Huzzah!
================================ Done (0.0000s) ================================

Say.("Hello, World!", justify: :right) { Say.("Huzzah!") }
================================================================ Hello, World! =
 -> Huzzah!
=============================================================== Done (0.0000s) =

# Banner

Say.banner("TEST")
= TEST =========================================================================

Say.banner("TEST", justify: :left)
= TEST =========================================================================

Say.banner("TEST", justify: :center)
===================================== TEST =====================================

Say.banner("TEST", justify: :right)
========================================================================= TEST =

# Header

Say.header("TEST")
= TEST =========================================================================

Say.header("TEST", justify: :left)
= TEST =========================================================================

Say.header("TEST", justify: :center)
===================================== TEST =====================================

Say.header("TEST", justify: :right)
========================================================================= TEST =

# Footer

Say.footer
= Done =========================================================================

Say.footer(justify: :left)
= Done =========================================================================

Say.footer(justify: :center)
===================================== Done =====================================

Say.footer(justify: :right)
========================================================================= Done =

# Section

Say.section("TEST")
================================================================================
= TEST =========================================================================
================================================================================

Say.section("TEST", justify: :left)
================================================================================
= TEST =========================================================================
================================================================================

Say.section("TEST", justify: :center)
================================================================================
===================================== TEST =====================================
================================================================================

Say.section("TEST", justify: :right)
================================================================================
========================================================================= TEST =
================================================================================
```

NOTE: The "line" methods will ignore justification attempts as there is no built in concept of columns for these.

```ruby
Say.("TEST", justify: :right)  # `justify: :right` is ignored.
 -> TEST
```

### Advanced Usage

All of the above examples are using the default interpolation template accessed via the `Say.<method>` methods. For advanced usage, one may access the Say::InterpolationTemplate directly and either use the predefined templates or specify their own.

#### Predefined interpolation templates

```ruby
# :hr
interpolation_template = Say::InterpolationTemplate::Builder.hr

interpolation_template.inspect                            # => "['=', ...]{}['=', ...]"
interpolation_template.interpolate                        # => "=="
interpolation_template.left_justify(length: 20)           # => "===================="

# :title (the default template, if none is specified)
interpolation_template = Say::InterpolationTemplate::Builder.title

interpolation_template.inspect                            # => ['=', ...] {} ['=', ...]
interpolation_template.interpolate("TEST")                # => "= TEST ="
interpolation_template.left_justify("TEST", length: 20)   # => "= TEST ============="
interpolation_template.center_justify("TEST", length: 20) # => "======= TEST ======="
interpolation_template.right_justify("TEST", length: 20)  # => "============= TEST ="

# :wtf
interpolation_template = Say::InterpolationTemplate::Builder.wtf

interpolation_template.inspect                            # => "['?', ...] {} ['?', ...]"
interpolation_template.interpolate("TEST")                # => "? TEST ?"
interpolation_template.left_justify("TEST", length: 20)   # => "? TEST ?????????????"
interpolation_template.center_justify("TEST", length: 20) # => "??????? TEST ???????"
interpolation_template.right_justify("TEST", length: 20)  # => "????????????? TEST ?"
```

#### Custom interpolation templates

```ruby
# Example 1
interpolation_template =
  Say::InterpolationTemplate.new(left_bookend: "╰(⇀︿⇀)つ-]═", left_fill: "-", right_fill: "-")

interpolation_template.inspect
# => "╰(⇀︿⇀)つ-]═['-', ...]{}['-', ...]"

interpolation_template.interpolate("TEST")
# => "╰(⇀︿⇀)つ-]═-TEST-"

interpolation_template.left_justify("TEST", length: 40)
# => "╰(⇀︿⇀)つ-]═-TEST-------------------------"

interpolation_template.center_justify("TEST", length: 40)
# => "╰(⇀︿⇀)つ-]═--------TEST------------------"

interpolation_template.right_justify("TEST", length: 40)
# => "╰(⇀︿⇀)つ-]═-------------------------TEST-"


# Example 2
interpolation_template =
  Say::InterpolationTemplate.new(
    left_bookend: "( •_•)O*¯",
    left_fill: "`·.·´",
    right_fill: "`·.·´",
    right_bookend: "¯°Q(•_• )")

interpolation_template.inspect
# => "( •_•)O*¯['`·.·´', ...]{}['`·.·´', ...]¯°Q(•_• )"

interpolation_template.interpolate("TEST")
# => "( •_•)O*¯`·.·´TEST`·.·´¯°Q(•_• )"

interpolation_template.left_justify("TEST")
# => "( •_•)O*¯`·.·´TEST`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.¯°Q(•_• )"

interpolation_template.center_justify("TEST")
# => "( •_•)O*¯`·.·´`·.·´`·.·´`·.·´`·.·`·.·´TEST`·.·´`·.·´`·.·´`·.·´`·.·´`·.·¯°Q(•_• )"

interpolation_template.right_justify("TEST")
# => "( •_•)O*¯`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.`·.·´TEST`·.·´¯°Q(•_• )"
```

### Progress Tracking

Use `Say.progress` to track long-running processing loops on a given interval. Set the interval to receive `say` updates only during on-interval ticks through the loop. The default interval is `1`, meaning every loop is considered on-interval.

#### Simple
```ruby
# The default interval is 1.
Say.progress do |interval|
  3.times do
    # Increment the interval's internal index by 1.
    interval.update

    interval.say("Test", :debug)
  end
end
= [20230604151646] Start (i=0) =================================================
[20230604151646]  >> Test (i=1)
[20230604151646]  >> Test (i=2)
[20230604151646]  >> Test (i=3)
= Done (0.0000s) ===============================================================
```

#### Advanced
```ruby
Say.progress("Progress Tracking Test", interval: 3) do |interval|
  0.upto(6) do |index|
    # Set the interval's internal index to the current index. This may be safer.
    interval.update(index)

    # Only "say" for on-interval ticks through the loop.
    interval.say("Before Update Interval.", :debug)
    # Optionally use a block to time a segment.
    interval.say("Progress Interval Block.") do
      sleep(0.025) # Do the work here.

      # Always "say", regardless of interval, in the usual way: with `Say.call`.
      Say.("Interval-Agnostic Update. Index: #{index}", :info)
    end
    interval.say("After Update Interval.", :debug)
  end
end
= [20230604151646] Progress Tracking Test (i=0) ================================
 -- Interval-Agnostic Update. Index: 0
 -- Interval-Agnostic Update. Index: 1
 -- Interval-Agnostic Update. Index: 2
[20230604151646]  >> Before Update Interval. (i=3)
= [20230604151646] Progress Interval Block. (i=3) ==============================
 -- Interval-Agnostic Update. Index: 3
= Done (0.0261s) ===============================================================

[20230604151646]  >> After Update Interval. (i=3)
 -- Interval-Agnostic Update. Index: 4
 -- Interval-Agnostic Update. Index: 5
[20230604151647]  >> Before Update Interval. (i=6)
= [20230604151647] Progress Interval Block. (i=6) ==============================
 -- Interval-Agnostic Update. Index: 6
= Done (0.0261s) ===============================================================

[20230604151647]  >> After Update Interval. (i=6)
= Done (0.1828s) ===============================================================
```

#### Manual

Internally, calling `say` on a Say::Progress::Interval object uses `Say.progress_line` to output the given message and index indicator. You may do the same even without an Interval object.

```ruby
# Given a message. (The default Type is :info.)
Say.progress_line("TEST", index: 3)
# => [20230604151647]  -- TEST (i=3)

Say.progress_line("TEST", :success, index: 3)
# => [20230604151647]  -> TEST (i=3)

# Given no message.
Say.progress_line(index: 3)
# => [20230604151647]  ... (i=3)
```

## Namespace Pollution

If you choose to `include Say` then your class will gain the following instance methods:
- `say`
- `say_banner`
- `say_footer`
- `say_header`
- `say_line`
- `say_progress`
- `say_progress_line`
- `say_section`
- `say_with_block`

... though you probably really only need `say`, and sometimes: `say_progress` and/or `say_progress_line`.

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
 -> Instance methods added by `include Say`: [:say, :say_banner, :say_footer, :say_header, :say_line, :say_progress, :say_progress_line, :say_section, :say_with_block]
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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. Or, run `rake` to run the tests plus linters as well as `yard` (to confirm proper YARD documentation practices). You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`, bump the latest ruby target versions etc. with `rake bump`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and attempt to push the `.gem` file to [rubygems.org](https://rubygems.org) -- NOTE: this gem doesn't live on rubygems.org because of a naming conflict, so the upload attempt can be aborted when 2FA is requested.

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
