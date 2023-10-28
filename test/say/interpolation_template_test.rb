# frozen_string_literal: true

require "test_helper"

class Say::InterpolationTemplateTest < Minitest::Spec
  describe "Say::InterpolationTemplate" do
    describe "#initialize" do
      subject { Say::InterpolationTemplate }

      context "GIVEN no args" do
        it "has the expected attributes" do
          result = subject.new
          value(result.interpolation_template_string).must_equal("{}")
          value(result.interpolation_sentinel).must_equal("{}")
        end
      end

      context "GIVEN a custom template..." do
        context "that contains the expected Sentinel" do
          it "has the expected attributes" do
            result = subject.new("- {} -")
            value(result.interpolation_template_string).must_equal("- {} -")
            value(result.interpolation_sentinel).must_equal("{}")
          end
        end

        context "that doesn't contain the expected Sentinel" do
          it "raises ArgumentError" do
            exception =
              value(-> {
                subject.new("- [] -")
              }).must_raise(ArgumentError)

            value(exception.message).must_equal(
              "interpolation_template_string (\"- [] -\") doesn't include "\
              "interpolation_sentinel: `{}`")
          end
        end

        context "that has a custom Sentinel" do
          it "has the expected attributes" do
            result = subject.new("- [] -", interpolation_sentinel: "[]")
            value(result.interpolation_template_string).must_equal("- [] -")
            value(result.interpolation_sentinel).must_equal("[]")
          end
        end
      end
    end

    describe "#interpolate" do
      context "GIVEN an empty interpolation template" do
        subject { Say::InterpolationTemplate.new("{}") }

        it "returns the expected String" do
          value(subject.interpolate("TEST")).must_equal("TEST")
        end

        it "returns an empty String, GIVEN nil" do
          value(subject.interpolate(nil)).must_equal("")
        end
      end

      context "GIVEN the default interpolation template" do
        subject { Say::InterpolationTemplate.new }

        it "returns the expected String" do
          value(subject.interpolate("TEST")).must_equal("TEST")
        end

        it "returns just the decoration string, GIVEN nil" do
          value(subject.interpolate(nil)).must_equal("")
        end
      end

      context "GIVEN a custom interpolation template" do
        subject { Say::InterpolationTemplate.new("=~ {} ~=") }

        it "returns the expected String" do
          value(subject.interpolate("TEST")).must_equal("=~ TEST ~=")
        end

        it "returns just the decoration string, GIVEN nil" do
          value(subject.interpolate(nil)).must_equal("=~  ~=")
        end
      end
    end

    describe "#decoration_length" do
      context "GIVEN an empty interpolation template" do
        subject { Say::InterpolationTemplate.new("{}") }

        it "returns 0" do
          value(subject.decoration_length).must_equal(0)
        end
      end

      context "GIVEN the default interpolation template" do
        subject { Say::InterpolationTemplate.new }

        it "returns 1" do
          value(subject.decoration_length).must_equal(0)
        end
      end

      context "GIVEN a custom interpolation template" do
        subject { Say::InterpolationTemplate.new("=~ {} ~=") }

        it "returns the expected Integer" do
          value(subject.decoration_length).must_equal(6)
        end
      end
    end

    describe "#split" do
      context "GIVEN an empty interpolation template" do
        subject { Say::InterpolationTemplate.new("{}") }

        it "returns an empty Array" do
          value(subject.split).must_equal([])
        end
      end

      context "GIVEN the default interpolation template" do
        subject { Say::InterpolationTemplate.new }

        it "returns the expected Array" do
          value(subject.split).must_equal([])
        end
      end

      context "GIVEN a custom interpolation template" do
        subject { Say::InterpolationTemplate.new("=~ {} ~=") }

        it "returns the expected String" do
          value(subject.split).must_equal(["=~", "~="])
        end
      end
    end

    describe "#left_side" do
      context "GIVEN an empty interpolation template" do
        subject { Say::InterpolationTemplate.new("{}") }

        it "returns an empty String" do
          value(subject.left_side).must_equal("")
        end
      end

      context "GIVEN the default interpolation template" do
        subject { Say::InterpolationTemplate.new }

        it "returns the expected String" do
          value(subject.left_side).must_equal("")
        end
      end

      context "GIVEN a custom interpolation template" do
        subject { Say::InterpolationTemplate.new("=~ {} ~=") }

        it "returns the expected String" do
          value(subject.left_side).must_equal("=~")
        end
      end
    end

    describe "#right_side" do
      context "GIVEN an empty interpolation template" do
        subject { Say::InterpolationTemplate.new("{}") }

        it "returns an empty String" do
          value(subject.right_side).must_equal("")
        end
      end

      context "GIVEN the default interpolation template" do
        subject { Say::InterpolationTemplate.new }

        it "returns the expected String" do
          value(subject.right_side).must_equal("")
        end
      end

      context "GIVEN a custom interpolation template" do
        subject { Say::InterpolationTemplate.new("=~ {} ~=") }

        it "returns the expected String" do
          value(subject.right_side).must_equal("~=")
        end
      end
    end
  end
end
