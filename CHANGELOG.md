## [Unreleased]
- Better definition of the `Say.say_with_block` method:
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
