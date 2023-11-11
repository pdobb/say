# frozen_string_literal: true

require "test_helper"

class Say::JustificationBehaviorsTest < Minitest::Spec
  describe "Say::JustificationBehaviors" do
    let(:simple_justifier) {
      Class.new do
        include Say::JustificationBehaviors

        private

        def justify(text)
          "_#{text}_"
        end
      end
    }

    let(:invalid_justifier) {
      Class.new do
        include Say::JustificationBehaviors
      end
    }

    describe "#initialize" do
      subject { simple_justifier }

      context "GIVEN no interpolation_template" do
        it "raises ArgumentError" do
          exception = value(-> { subject.new }).must_raise(ArgumentError)

          value(exception.message).must_equal(
            "missing keyword: :interpolation_template")
        end
      end

      context "GIVEN all required arguments" do
        it "uses the expected default for #total_length" do
          result = subject.new(interpolation_template: Object.new)
          value(result.total_length).must_equal(80)
        end
      end

      context "GIVEN all required and optional arguments" do
        it "uses the given value for #total_length" do
          result = subject.new(interpolation_template: Object.new, length: 20)
          value(result.total_length).must_equal(20)
        end
      end
    end

    describe "#call" do
      let(:interpolation_template1) { Say::InterpolationTemplate.new }

      context "GIVEN a properly defined subclass" do
        subject {
          simple_justifier.new(interpolation_template: interpolation_template1)
        }

        context "GIVEN no text" do
          it "uses the expected default" do
            result = subject.call
            value(result).must_equal("__")
          end
        end

        context "GIVEN text" do
          it "uses the block result" do
            result = subject.call("TEXT")
            value(result).must_equal("_TEXT_")
          end
        end

        context "GIVEN a block" do
          it "uses the block result" do
            result = subject.call("TEXT") { "BLOCK_RESULT" }
            value(result).must_equal("_BLOCK_RESULT_")
          end
        end
      end

      context "GIVEN a subclass that doesn't implement #justify" do
        subject {
          invalid_justifier.new(interpolation_template: interpolation_template1)
        }

        it "raises NotImplementedError" do
          value(-> { subject.call }).must_raise(NotImplementedError)
        end
      end
    end
  end
end
