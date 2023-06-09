# frozen_string_literal: true

require "test_helper"

class Say::LJBannerTest < Minitest::Spec
  describe "Say::LJBanner" do
    describe "#initialize" do
      context "GIVEN no args" do
        subject { Say::LJBanner }

        it "has the expected attributes" do
          result = subject.new
          value(result.interpolation_template).must_be_kind_of(
            Say::InterpolationTemplate)
          value(result.columns).must_equal(80)
        end
      end
    end

    describe "#call" do
      context "GIVEN the default interpolation template" do
        subject { Say::LJBanner.new }

        context "GIVEN no args" do
          it "returns the expected String" do
            # rubocop:disable Layout/LineLength
            value(subject.call).must_equal(
              "=  =============================================================================")
            # rubocop:enable Layout/LineLength
          end
        end

        context "GIVEN no columns arg" do
          context "GIVEN a short String" do
            it "returns the expected String" do
              # rubocop:disable Layout/LineLength
              value(subject.call("TEST")).must_equal(
                "= TEST =========================================================================")
              # rubocop:enable Layout/LineLength
            end
          end

          context "GIVEN an extra-long String" do
            it "returns the expected String" do
              # rubocop:disable Layout/LineLength
              value(subject.call("T" * 90)).must_equal(
                "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =")
              # rubocop:enable Layout/LineLength
            end
          end
        end

        context "GIVEN a columns arg" do
          subject { Say::LJBanner.new(columns: 20) }

          context "GIVEN a short String" do
            it "returns the expected String" do
              value(subject.call("TEST")).must_equal("= TEST =============")
            end
          end

          context "GIVEN an extra-long String" do
            it "returns the expected String" do
              value(subject.call("T" * 30)).must_equal(
                "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =")
            end
          end
        end

        context "GIVEN columns arg < the given String" do
          subject { Say::LJBanner.new(columns: 0) }

          it "returns the expected String" do
            value(subject.call("TEST")).must_equal("= TEST =")
          end
        end
      end

      context "GIVEN a custom interpolation template" do
        subject { Say::LJBanner.new("{}=") }

        context "GIVEN no args" do
          it "returns the expected String" do
            # rubocop:disable Layout/LineLength
            value(subject.call).must_equal(
              "================================================================================")
            # rubocop:enable Layout/LineLength
          end
        end

        context "GIVEN no columns arg" do
          context "GIVEN a short String" do
            it "returns the expected String" do
              # rubocop:disable Layout/LineLength
              value(subject.call("TEST")).must_equal(
                "TEST============================================================================")
              # rubocop:enable Layout/LineLength
            end
          end

          context "GIVEN an extra-long String" do
            it "returns the expected String" do
              # rubocop:disable Layout/LineLength
              value(subject.call("T" * 90)).must_equal(
                "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT=")
              # rubocop:enable Layout/LineLength
            end
          end
        end

        context "GIVEN a columns arg" do
          subject { Say::LJBanner.new("{}=", columns: 20) }

          context "GIVEN a short String" do
            it "returns the expected String" do
              value(subject.call("TEST")).must_equal("TEST================")
            end
          end

          context "GIVEN an extra-long String" do
            it "returns the expected String" do
              value(subject.call("T" * 30)).must_equal(
                "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT=")
            end
          end
        end
      end

      context "GIVEN a block" do
        subject { Say::LJBanner.new(columns: 0) }

        it "uses the result of the block as the text for the banner" do
          value(subject.call("NOPE") { "TEST_BLOCK" }).must_equal(
            "= TEST_BLOCK =")
        end
      end
    end

    describe "Say::LJBanner::ITFiller" do
      describe "#initialize" do
        subject { Say::LJBanner::ITFiller }

        it "has the expected attributes" do
          result =
            subject.new(banner: Object.new, interpolated_text: String.new)
          value(result.banner).must_be_kind_of(Object)
          value(result.interpolated_text).must_be_kind_of(String)
        end
      end

      describe "#call" do
        context "GIVEN a fill pattern" do
          subject {
            Say::LJBanner::ITFiller.new(
              banner: Say::LJBanner.new("-{}-", columns: 20),
              interpolated_text: "-TEST-")
          }

          it "returns the text as is" do
            value(subject.call).must_equal("-TEST---------------")
          end
        end

        context "GIVEN no fill pattern" do
          subject {
            Say::LJBanner::ITFiller.new(
              banner: Say::LJBanner.new("{}"),
              interpolated_text: "TEST")
          }

          it "returns the text as is" do
            value(subject.call).must_equal("TEST")
          end
        end
      end
    end

    describe "Say::LJBanner::ITBuilder" do
      describe "::TYPES" do
        subject { Say::LJBanner::ITBuilder }

        let(:types) { Say::LJBanner::ITBuilder::TYPES }

        it "defines a singleton method for each key" do
          types.each_key do |key|
            value(subject.public_send(key)).must_be_kind_of(
              Say::InterpolationTemplate)
          end
        end
      end

      describe ".call" do
        subject { Say::LJBanner::ITBuilder }

        context "GIVEN a Say::InterpolationTemplate object" do
          it "returns the given Say::InterpolationTemplate object" do
            interpolation_template = Say::InterpolationTemplate.new("^{}^")
            value(subject.call(interpolation_template)).must_equal(
              interpolation_template)
          end
        end
      end
    end
  end
end
