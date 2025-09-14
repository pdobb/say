# frozen_string_literal: true

require "test_helper"

class Say::CenterJustifierTest < Minitest::Spec
  describe "Say::CenterJustifier" do
    describe "#call" do
      context "GIVEN the default interpolation template" do
        subject {
          Say::CenterJustifier.new(
            interpolation_template: Say::InterpolationTemplate::Builder.title,
          )
        }

        context "GIVEN no args" do
          it "returns the expected String" do
            # rubocop:disable Layout/LineLength
            _(subject.call).must_equal(
              "=======================================  =======================================",
            )
            # rubocop:enable Layout/LineLength
          end
        end

        context "GIVEN no length arg" do
          context "GIVEN a short String" do
            it "returns the expected String" do
              # rubocop:disable Layout/LineLength
              _(subject.call("TEST")).must_equal(
                "===================================== TEST =====================================",
              )
              # rubocop:enable Layout/LineLength
            end
          end

          context "GIVEN an extra-long String" do
            it "returns the expected String" do
              # rubocop:disable Layout/LineLength
              _(subject.call("T" * 90)).must_equal(
                "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =",
              )
              # rubocop:enable Layout/LineLength
            end
          end
        end

        context "GIVEN a length arg" do
          subject {
            Say::CenterJustifier.new(
              interpolation_template: Say::InterpolationTemplate::Builder.title,
              length: 20,
            )
          }

          context "GIVEN a short String" do
            it "returns the expected String" do
              _(subject.call("TEST")).must_equal("======= TEST =======")
            end
          end

          context "GIVEN an extra-long String" do
            it "returns the expected String" do
              _(subject.call("T" * 30)).must_equal(
                "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =",
              )
            end
          end
        end

        context "GIVEN length arg < the given String" do
          subject {
            Say::CenterJustifier.new(
              interpolation_template: Say::InterpolationTemplate::Builder.title,
              length: 0,
            )
          }

          it "returns the expected String" do
            _(subject.call("TEST")).must_equal("= TEST =")
          end
        end
      end

      context "GIVEN a custom interpolation template" do
        subject {
          Say::CenterJustifier.new(
            interpolation_template:
              Say::InterpolationTemplate.new(left_fill: "-", right_fill: "-"),
          )
        }

        context "GIVEN no args" do
          it "returns the expected String" do
            # rubocop:disable Layout/LineLength
            _(subject.call).must_equal(
              "--------------------------------------------------------------------------------",
            )
            # rubocop:enable Layout/LineLength
          end
        end

        context "GIVEN no length arg" do
          subject {
            Say::CenterJustifier.new(
              interpolation_template:
                Say::InterpolationTemplate::Builder.double_line,
            )
          }

          context "GIVEN a short String" do
            it "returns the expected String" do
              # rubocop:disable Layout/LineLength
              _(subject.call("TEST")).must_equal(
                "======================================TEST======================================",
              )
              # rubocop:enable Layout/LineLength
            end
          end

          context "GIVEN an extra-long String" do
            it "returns the expected String" do
              # rubocop:disable Layout/LineLength
              _(subject.call("T" * 30)).must_equal(
                "=========================TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT=========================",
              )
              # rubocop:enable Layout/LineLength
            end
          end
        end

        context "GIVEN a length arg" do
          subject {
            Say::CenterJustifier.new(
              interpolation_template:
                Say::InterpolationTemplate::Builder.double_line,
              length: 20,
            )
          }

          context "GIVEN a short String" do
            it "returns the expected String" do
              _(subject.call("TEST")).must_equal("========TEST========")
            end
          end

          context "GIVEN an extra-long String" do
            it "returns the expected String" do
              _(subject.call("T" * 30)).must_equal(
                "=TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT=",
              )
            end
          end
        end
      end

      context "GIVEN a block" do
        subject {
          Say::CenterJustifier.new(
            interpolation_template: Say::InterpolationTemplate::Builder.title,
            length: 0,
          )
        }

        it "uses the result of the block as the text for the banner" do
          _(subject.call("NOPE") { "TEST_BLOCK" }).must_equal(
            "= TEST_BLOCK =",
          )
        end
      end
    end
  end
end
