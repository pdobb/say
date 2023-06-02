# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  enable_coverage :branch
  enable_coverage_for_eval
  add_filter "/bin/"
  add_filter "/test/"
end
