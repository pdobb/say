# frozen_string_literal: true

require "support/simplecov"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "say"

require "minitest/autorun"
require "support/reporters"

require "much-stub"

class Minitest::Spec
  after do
    MuchStub.unstub!
  end
end

def context(...)
  describe(...)
end
