## [Unreleased]

- Rename `Say::InterpolationTemplate::Builder.hr` -> `Say::InterpolationTemplate::Builder.double_line`

## [0.6.1] - 2025-07-27

- Backport: Add `Say.clear_esc` method for clearing `^C` (`ctrl+c` output) from $stdout.

## [0.6.0] - 2024-11-22

- Update minimum Ruby version from 2.7 -> 3.1

## [0.5.2] - 2023-11-21

- Internal updates to style, etc. No outward-facing changes.

## [0.5.1] - 2023-11-11

#### Public API Updates!

- Add `Say.<type>` convenience methods. These are single-argument alternatives to `Say.line(text, type)`:
  - `Say.debug("TEST")   # => " >> TEST"`
  - `Say.error("TEST")   # => " ** TEST"`
  - `Say.info("TEST")    # => " -- TEST"`
  - `Say.success("TEST") # => " -> TEST"`
  - `Say.warn("TEST")    # => " !¡ TEST"`

## [0.5.0] - 2023-11-11

Complete rewrite of Say::InterpolationTemplate.

- Say::InterpolationTemplate is now defined through piecemeal attributes, instead of by passing in a representative interpolation template String. This allows for very obvious and fine-grained control of which parts of the template are which.
- Add the ability to specify left/right bookends on Say::InterpolationTemplate. These allow for specifying text that should always appear on the left/right end of the interpolated text, regardless of length restrictions.

Remove the Say::LJBanner, Say::CJBanner, and Say::RJBanner classes.

- Instead, we now have Say::JustifierBehaviors and implementing classes: Say::LeftJustifier, Say::CenterJustifier, and Say::RightJustifier.
- These new classes are internally instantiated when calling Say::InterpolationTemplate#left_justify, Say::InterpolationTemplate#center_justify, and Say::InterpolationTemplate#right_justify, respectively.

Updates to README to show advanced usage using the newly rewritten Say::InterpolationTemplate class.

### BREAKING CHANGES:

- Internal classes and associated invocations have changed... see above and see new README section on Advanced Usage.

## [Unreleased Version -- Internal Only]

### Non-breaking Changes:

- Add Say::CJBanner and Say::RJBanner, for center-justified and right-justified banners. Can now use `justify: :left` (the default, if not specified), `justify: :center`, and `justify: :right` on banner-related calls:

  - `Say.(..., justify: :[left|center|right]) { ... }`
  - `Say.banner(..., justify: :[left|center|right])`
  - `Say.header(..., justify: :[left|center|right])`
  - `Say.footer(..., justify: :[left|center|right])`
  - `Say.section(..., justify: :[left|center|right])`

- Internal Changes:
  - Add Say::Message as an abstract class/concept for the old Say#build_message
  - Rename Say::LJBanner::ITBuilder -> Say::LJBanner::InterpolationTemplateBuilder
  - Rename Say::LJBanner::ITFiller -> Say::LJBanner::InterpolationTemplateFiller

### BREAKING CHANGES:

- None

#### Public API Updates!

- `Say.write` no longer takes arg: `silent`.

## [0.4.0] - 2023-06-04

### BREAKING CHANGES:

- None

#### Public API Updates!

- Add `Say.section` and `say_section` for 3-line banners that really visually split up your output into major sections.
- `Say.message` was renamed to `Say.build_message` and is no longer part of the public API.
- When using `include Say`, `say_message` has been removed.

### Non-breaking Changes:

- `Say.banner` will now call `Say.write`, internally. This means it now outputs directly as well, instead of only returning a String.
- Prepend a timestamp to the output text from `Say.progress` and `Say.progress_line`.

## [0.3.1] - 2023-06-02

#### Public API Updates!

- Add `Say.progress_line` and `Say#progress_line` for printing a message along with a given `index` indicator. `Say.progress` now uses this internally so that calling `say` on an Interval object automatically includes the `index` indicator.

## [0.3.0] - 2023-06-02

### BREAKING CHANGES:

- Remove `warning` from Say::Types (keep `warn`)

#### Public API Updates!

- The updated public API when not including Say is:
  - `Say.line` (was `Say.result`)
- The updated public API when including Say is:
  - `say_line` (was `say_result`)

### Non-breaking Changes:

- Add to public API: `Say.progress` and `say_progress`.
  - Use this to track long-running processing loops on a given interval.
  - See the [README](https://github.com/pdobb/say#progress-tracking) for more details.
- Internal Changes: Abstract Say#banner using new classes/concepts:
  - Say::InterpolationTemplate
  - Say::LJBanner (Left-Justified Banner)

## [0.2.0] - 2023-05-21

### BREAKING CHANGES:

- None

#### Public API Updates!

- The updated public API when not including Say is:
  | Updated API Method | Previous API Method |
  |--------------------|---------------------|
  | `Say.()` or `Say.call` | `Say.say` |
  | `Say.with_block` | `Say.say_with_block` |
  | `Say.header` | `Say.say_header` |
  | `Say.result` | `Say.say_item` |
  | `Say.footer` | `Say.say_footer` |
  | `Say.banner` | `Say.build_banner` |
  | `Say.message` | `Say.build_message` |
  | `Say.write` | `Say.do_say` |

- The updated public API when including Say is:
  | Current API Method | Previous API Method |
  |--------------------|---------------------|
  | `say` | (no change) |
  | `say_with_block` | (no change) |
  | `say_header` | (no change) |
  | `say_result` | `say_item` |
  | `say_footer` | (no change) |
  | `say_banner` | `build_banner` |
  | `say_message` | `build_message` |
  | | (`do_say` has been removed, `write` not defined) |

### Non-breaking Changes:

- When calling `Say.call`, `Say.result`, and `Say.message` without passing in a message String, the "message" result will now be `" ..."`, instead of raising ArgumentError.

- Better definition of the `Say.with_block` method:

  1. Rename `footer_message` kwarg to just `footer`
  2. Make `header_message` into a kwarg and rename to `header`
  3. Make `header` an optional argument

- Display processing time info via `Say.say_with_block`. e.g.

  ```
  # Instead of just:
  = Processing ===================================================================
    # ...
  = Done =========================================================================

  # We'll now display, e.g.:
  = Processing ===================================================================
    # ...
  = Done (0.0000s) ===============================================================
  ```

## [0.1.0] Initial Release - 2023-05-20

- Define basic functionality for this gem:
  - `Say.say(message, type = nil, &block)`
  - `Say.say_with_block(header_message, footer_message: "Done")`
  - `Say.say_header(message = nil, **kwargs)`
  - `Say.say_item(message, **kwargs)`
  - `Say.say_footer(message = "Done", **kwargs)`
  - `Say.build_banner(message = nil, columns: MAX_COLUMNS)`
  - `Say.build_message(message, type: nil)`
  - `Say.do_say(*messages, silent: false)`
