# frozen_string_literal: true

require "minitest/reporters"

Minitest::Test.make_my_diffs_pretty!

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new)
