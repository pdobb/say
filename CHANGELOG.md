## [Unreleased]

### BREAKING CHANGES:

#### Public API Updates!
- `Say.write` no longer takes arg: `silent`.

## [0.4.0] - 2023-06-04

### BREAKING CHANGES:

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
  - `Say.line`                (was `Say.result`)
- The updated public API when including Say is:
  - `say_line`                (was `say_result`)

### Non-breaking Changes:
- Add to public API: `Say.progress` and `say_progress`.
  - Use this to track long-running processing loops on a given interval.
  - See the [README](https://github.com/pdobb/say#progress-tracking) for more details.
- Internal Changes: Abstract Say#banner using new classes/concepts:
  - Say::InterpolationTemplate
  - Say::LJBanner (Left-Justified Banner)

## [0.2.0] - 2023-05-21

### BREAKING CHANGES:

#### Public API Updates!
- The updated public API when not including Say is:
  - `Say.()` (or `Say.call`)  (was `Say.say`)
  - `Say.with_block`          (was `Say.say_with_block`)
  - `Say.header`              (was `Say.say_header`)
  - `Say.result`              (was `Say.say_item`)
  - `Say.footer`              (was `Say.say_footer`)
  - `Say.banner`              (was `Say.build_banner`)
  - `Say.message`             (was `Say.build_message`)
  - `Say.write`               (was `Say.do_say`)
- The updated public API when including Say is:
  - `say`                     (no change)
  - `say_with_block`          (no change)
  - `say_header`              (no change)
  - `say_result`              (was `say_item`)
  - `say_footer`              (no change)
  - `say_banner`              (was `build_banner`)
  - `say_message`             (was `build_message`)
  -                           (`do_say` has been removed and `write` is not defined)

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
