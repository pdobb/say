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
    end

    describe "Say::LJBanner::ITBuilder" do
      describe "::TYPES" do
        subject { Say::LJBanner::ITBuilder }

        let(:types) { Say::LJBanner::ITBuilder::TYPES }

        it "defines a singleton method for each key" do
          types.each_key do |key|
            value(subject).must_respond_to(key)
          end
        end
      end
    end
  end
end
