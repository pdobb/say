# frozen_string_literal: true

require "test_helper"

class TestSay < Minitest::Spec
  describe "Say" do
    describe "::MAX_COLUMNS" do
      it "returns the expected Integer" do
        value(Say::MAX_COLUMNS).must_equal(80)
      end
    end

    describe "::TYPES" do
      it "defines the expected type keys" do
        value(Say::TYPES.keys).must_equal(
          %i[debug error info success warn warning])
      end

      it "defaults to :success" do
        value(Say::TYPES.default).must_equal(Say::TYPES[:success])
      end

      it "has an immutable default value" do
        assert_raises(FrozenError) do
          Say::TYPES[:unknown_type] << "NOPE"
        end
      end
    end

    describe "#say" do
      subject { Say }

      describe "GIVEN no block" do
        before do
          MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
        end

        it "puts and returns the formatted message" do
          value(subject.say("TEST")).must_be_instance_of(String)
          value(@puts_call.args).must_equal([" -> TEST"])
        end
      end

      describe "GIVEN a block" do
        before do
          @puts_calls = []
          MuchStub.on_call($stdout, :puts) { |call| @puts_calls << call }
        end

        it "puts header and footer banners, "\
           "and returns the value from the block" do
          value(subject.say("TEST") { "TEST_BLOCK_RETURN_VALUE" }).must_equal(
            "TEST_BLOCK_RETURN_VALUE")

          # rubocop:disable Layout/LineLength
          value(@puts_calls[0].args).must_equal([
            "= TEST ========================================================================="
          ])
          value(@puts_calls[1].args).must_equal([
            "= Done (0.0000s) ===============================================================",
            "\n"
          ])
          # rubocop:enable Layout/LineLength
        end
      end
    end

    describe "#say_with_block" do
      subject { Say }

      describe "GIVEN no block" do
        it "raises ArgumentError" do
          value(-> { subject.say_with_block("TEST") }).must_raise(ArgumentError)
        end
      end

      describe "GIVEN a block" do
        before do
          @puts_calls = []
          MuchStub.on_call($stdout, :puts) { |call| @puts_calls << call }
        end

        it "puts header and footer banners, "\
           "and returns the value from the block" do
          value(subject.say_with_block("TEST") { "TEST_BLOCK_RETURN_VALUE" }).
            must_equal("TEST_BLOCK_RETURN_VALUE")

          # rubocop:disable Layout/LineLength
          value(@puts_calls[0].args).must_equal([
            "= TEST ========================================================================="
          ])
          value(@puts_calls[1].args).must_equal([
            "= Done (0.0000s) ===============================================================",
            "\n"
          ])
          # rubocop:enable Layout/LineLength
        end
      end
    end

    describe "#say_header" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        value(subject.say_header).must_equal(
          "================================================================================")
        value(@puts_call.args).must_equal([
          "================================================================================"
        ])
        # rubocop:enable Layout/LineLength
      end

      it "puts and returns the expected String, GIVEN a message" do
        # rubocop:disable Layout/LineLength
        value(subject.say_header("TEST")).must_equal(
          "= TEST =========================================================================")
        value(@puts_call.args).must_equal([
          "= TEST ========================================================================="
        ])
        # rubocop:enable Layout/LineLength
      end

      context "GIVEN an extra long String" do
        it "puts and returns the full String anyway, with minimal decoration" do
          # rubocop:disable Layout/LineLength
          value(subject.say_header("T" * 90)).must_equal(
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =")
          value(@puts_call.args).must_equal([
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ="
          ])
          # rubocop:enable Layout/LineLength
        end
      end
    end

    describe "#say_item" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String" do
        value(subject.say_item("TEST")).must_equal(" -> TEST")
        value(@puts_call.args).must_equal([" -> TEST"])
      end

      it "puts and returns the expected String, GIVEN a type" do
        value(subject.say_item("TEST", type: :info)).must_equal(" -- TEST")
        value(@puts_call.args).must_equal([" -- TEST"])
      end

      context "GIVEN an extra long String" do
        it "puts and returns the full String" do
          # rubocop:disable Layout/LineLength
          value(subject.say_item("T" * 90)).must_equal(
            " -> TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT")
          value(@puts_call.args).must_equal([
            " -> TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"
          ])
          # rubocop:enable Layout/LineLength
        end
      end
    end

    describe "#say_footer" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        value(subject.say_footer).must_equal(
          "= Done =========================================================================\n\n")
        value(@puts_call.args).must_equal([
          "= Done =========================================================================",
          "\n"
        ])
        # rubocop:enable Layout/LineLength
      end

      it "puts and returns the expected String, GIVEN a message" do
        # rubocop:disable Layout/LineLength
        value(subject.say_footer("TEST")).must_equal(
          "= TEST =========================================================================\n\n")
        value(@puts_call.args).must_equal([
          "= TEST =========================================================================",
          "\n"
        ])
        # rubocop:enable Layout/LineLength
      end

      context "GIVEN an extra long String" do
        it "puts and returns the full String anyway, with minimal decoration" do
          # rubocop:disable Layout/LineLength
          value(subject.say_footer("T" * 90)).must_equal(
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =\n\n")
          value(@puts_call.args).must_equal([
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =",
            "\n"
          ])
          # rubocop:enable Layout/LineLength
        end
      end
    end

    describe "#build_banner" do
      subject { Say }

      it "returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        value(subject.build_banner).must_equal(
          "================================================================================")
        # rubocop:enable Layout/LineLength
      end

      it "returns the expected String, GIVEN an empty message" do
        # rubocop:disable Layout/LineLength
        value(subject.build_banner("")).must_equal(
          "=  =============================================================================")
        # rubocop:enable Layout/LineLength
      end

      it "returns the expected String, GIVEN a short message" do
        # rubocop:disable Layout/LineLength
        value(subject.build_banner("TEST")).must_equal(
          "= TEST =========================================================================")
        # rubocop:enable Layout/LineLength
      end

      it "returns the expected String, GIVEN a long message" do
        # rubocop:disable Layout/LineLength
        value(subject.build_banner("T" * 90)).must_equal(
          "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =")
        # rubocop:enable Layout/LineLength
      end
    end

    describe "#build_message" do
      subject { Say }

      it "raises ArgumentError, GIVEN no message" do
        value(-> { subject.build_message }).must_raise(ArgumentError)
      end

      it "returns the expected String" do
        value(subject.build_message("TEST")).must_equal(" -> TEST")
      end

      it "returns the expected String, GIVEN a type" do
        value(subject.build_message("TEST", type: :info)).must_equal(" -- TEST")
      end
    end

    describe "#do_say" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      context "GIVEN silent = false" do
        it "puts and returns the expected String, GIVEN a single message" do
          value(subject.do_say("TEST")).must_equal("TEST")
          value(@puts_call.args).must_equal(["TEST"])
        end

        it "puts and returns the expected String, GIVEN many messages" do
          value(subject.do_say("TEST 1", "TEST 2")).must_equal("TEST 1\nTEST 2")
          value(@puts_call.args).must_equal(["TEST 1", "TEST 2"])
        end
      end

      context "GIVEN silent = true" do
        it "returns the expected String, GIVEN a single message" do
          value(subject.do_say("TEST", silent: true)).must_equal("TEST")
          value(@puts_call).must_be_nil
        end

        it "returns the expected String, GIVEN more than one message" do
          value(subject.do_say("TEST 1", "TEST 2", silent: true)).must_equal(
            "TEST 1\nTEST 2")
          value(@puts_call).must_be_nil
        end
      end
    end
  end
end
