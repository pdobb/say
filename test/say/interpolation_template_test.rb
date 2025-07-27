# frozen_string_literal: true

require "test_helper"

class Say::InterpolationTemplateTest < Minitest::Spec
  describe "Say::InterpolationTemplate" do
    describe "#initialize" do
      subject { Say::InterpolationTemplate }

      context "GIVEN no args" do
        it "has the expected default attributes" do
          result = subject.new

          _(result.inspect).must_equal("{}")

          _(result.left_bookend).must_equal("")
          _(result.left_fill).must_equal("")
          _(result.left_spacer).must_equal("")
          _(result.right_spacer).must_equal("")
          _(result.right_fill).must_equal("")
          _(result.right_bookend).must_equal("")
        end
      end

      context "GIVEN custom attributes" do
        it "has the expected attributes" do
          result =
            subject.new(
              left_bookend: "LBE",
              left_fill: "LF",
              left_spacer: "_LS_",
              right_spacer: "_RS_",
              right_fill: "RF",
              right_bookend: "RBE",
            )

          _(result.inspect).must_equal(
            "LBE['LF', ...]_LS_{}_RS_['RF', ...]RBE",
          )

          _(result.left_bookend).must_equal("LBE")
          _(result.left_fill).must_equal("LF")
          _(result.left_spacer).must_equal("_LS_")
          _(result.right_spacer).must_equal("_RS_")
          _(result.right_fill).must_equal("RF")
          _(result.right_bookend).must_equal("RBE")
        end
      end
    end

    describe "#to_h" do
      subject { Say::InterpolationTemplate }

      it "returns the expected Hash" do
        result = subject.new

        _(result.to_h).must_equal({
          left_bookend: "",
          left_fill: "",
          left_spacer: "",
          right_spacer: "",
          right_fill: "",
          right_bookend: "",
        })
      end
    end

    describe "#inspect" do
      subject { Say::InterpolationTemplate }

      context "GIVEN an empty interpolation template" do
        it "returns the expected String" do
          result = subject.new

          _(result.inspect).must_equal("{}")
        end
      end

      context "GIVEN a custom interpolation template" do
        subject {
          Say::InterpolationTemplate.new(
            left_bookend: "=",
            left_fill: "~",
            left_spacer: " ",
            right_spacer: " ",
            right_fill: "~",
            right_bookend: "=",
          )
        }

        it "returns the expected String" do
          _(subject.inspect).must_equal("=['~', ...] {} ['~', ...]=")
        end
      end
    end

    describe "#interpolate" do
      context "GIVEN an empty interpolation template" do
        subject { Say::InterpolationTemplate.new }

        it "returns the expected String" do
          _(subject.interpolate("TEST")).must_equal("TEST")
        end

        it "returns an empty String, GIVEN nil" do
          _(subject.interpolate(nil)).must_equal("")
        end
      end

      context "GIVEN a custom interpolation template" do
        subject {
          Say::InterpolationTemplate.new(
            left_bookend: "=",
            left_fill: "~",
            left_spacer: " ",
            right_spacer: " ",
            right_fill: "~",
            right_bookend: "=",
          )
        }

        it "returns the expected String" do
          _(subject.interpolate("TEST")).must_equal("=~ TEST ~=")
        end

        it "returns just the decoration string, GIVEN nil" do
          _(subject.interpolate(nil)).must_equal("=~  ~=")
        end
      end
    end

    describe "#wrap" do
      context "GIVEN an empty interpolation template" do
        subject { Say::InterpolationTemplate.new }

        it "returns the expected String" do
          _(subject.wrap("TEST")).must_equal("TEST")
        end

        it "returns an empty String, GIVEN nil" do
          _(subject.wrap(nil)).must_equal("")
        end
      end

      context "GIVEN a custom interpolation template" do
        subject {
          Say::InterpolationTemplate.new(
            left_bookend: "=",
            left_fill: "~",
            left_spacer: " ",
            right_spacer: " ",
            right_fill: "~",
            right_bookend: "=",
          )
        }

        it "returns the expected String" do
          _(subject.wrap("TEST")).must_equal("~ TEST ~")
        end

        it "returns just the decoration string, GIVEN nil" do
          _(subject.wrap(nil)).must_equal("~  ~")
        end
      end
    end

    describe "#left_justify" do
      before do
        MuchStub.on_call(Say::LeftJustifier, :new) { |call|
          @left_justifier_new_call = call
          ->(text) { text }
        }
      end

      subject { Say::InterpolationTemplate.new }

      it "collaborates with Say::LeftJustifier" do
        result = subject.left_justify("TEST")

        _(@left_justifier_new_call).wont_be_nil
        _(result).must_equal("TEST")
      end
    end

    describe "#center_justify" do
      before do
        MuchStub.on_call(Say::CenterJustifier, :new) { |call|
          @center_justifier_new_call = call
          ->(text) { text }
        }
      end

      subject { Say::InterpolationTemplate.new }

      it "collaborates with Say::LeftJustifier" do
        result = subject.center_justify("TEST")

        _(@center_justifier_new_call).wont_be_nil
        _(result).must_equal("TEST")
      end
    end

    describe "#right_justify" do
      before do
        MuchStub.on_call(Say::RightJustifier, :new) { |call|
          @right_justifier_new_call = call
          ->(text) { text }
        }
      end

      subject { Say::InterpolationTemplate.new }

      it "collaborates with Say::LeftJustifier" do
        result = subject.right_justify("TEST")

        _(@right_justifier_new_call).wont_be_nil
        _(result).must_equal("TEST")
      end
    end

    describe "#left_fill?" do
      context "GIVEN no left fill" do
        subject {
          Say::InterpolationTemplate.new(left_fill: [nil, ""].sample)
        }

        it "returns false" do
          _(subject.left_fill?).must_equal(false)
        end
      end

      context "GIVEN a left fill" do
        subject { Say::InterpolationTemplate.new(left_fill: " ") }

        it "returns true" do
          _(subject.left_fill?).must_equal(true)
        end
      end
    end

    describe "#right_fill?" do
      context "GIVEN no right fill" do
        subject {
          Say::InterpolationTemplate.new(right_fill: [nil, ""].sample)
        }

        it "returns false" do
          _(subject.right_fill?).must_equal(false)
        end
      end

      context "GIVEN a right fill" do
        subject { Say::InterpolationTemplate.new(right_fill: " ") }

        it "returns true" do
          _(subject.right_fill?).must_equal(true)
        end
      end
    end

    describe "Say::InterpolationTemplate::Builder" do
      describe ".hr" do
        subject { Say::InterpolationTemplate::Builder }

        it "returns the expected Say::InterpolationTemplate" do
          result = subject.hr

          _(result.to_h).must_equal({
            left_bookend: "",
            left_fill: "=",
            left_spacer: "",
            right_spacer: "",
            right_fill: "=",
            right_bookend: "",
          })
        end
      end

      describe ".title" do
        subject { Say::InterpolationTemplate::Builder }

        it "returns the expected Say::InterpolationTemplate" do
          result = subject.title

          _(result.to_h).must_equal({
            left_bookend: "",
            left_fill: "=",
            left_spacer: " ",
            right_spacer: " ",
            right_fill: "=",
            right_bookend: "",
          })
        end
      end

      describe ".wtf" do
        subject { Say::InterpolationTemplate::Builder }

        it "returns the expected Say::InterpolationTemplate" do
          result = subject.wtf

          _(result.to_h).must_equal({
            left_bookend: "",
            left_fill: "?",
            left_spacer: " ",
            right_spacer: " ",
            right_fill: "?",
            right_bookend: "",
          })
        end
      end

      describe ".call" do
        subject { Say::InterpolationTemplate::Builder }

        context "GIVEN an interpolation template object" do
          let(:interpolation_template1) {
            Say::InterpolationTemplate.new(left_bookend: "TEST")
          }

          it "returns the given object" do
            result = subject.call(interpolation_template1)

            _(result.to_h.fetch(:left_bookend)).must_equal("TEST")
          end
        end

        context "GIVEN a Hash" do
          let(:interpolation_template_attributes1) {
            { left_bookend: "TEST" }
          }

          it "returns the expected interpolation template object" do
            result =
              subject.call(
                interpolation_template_attributes1,
                interpolation_template_class: Say::InterpolationTemplate,
              )

            _(result.to_h.fetch(:left_bookend)).must_equal("TEST")
          end
        end
      end
    end
  end
end
