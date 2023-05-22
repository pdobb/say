# frozen_string_literal: true

require "test_helper"

class SayTest < Minitest::Spec
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

    describe ".call" do
      subject { Say }

      describe "GIVEN no block" do
        before do
          MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
        end

        context "GIVEN no message" do
          it "puts and returns the expected String" do
            value(subject.call).must_equal(" ...")
            value(@puts_call.args).must_equal([" ..."])
          end
        end

        context "GIVEN a message" do
          it "puts and returns the expected formatted message String" do
            value(subject.call("TEST")).must_equal(" -> TEST")
            value(@puts_call.args).must_equal([" -> TEST"])
          end

          it "respects Ruby's call notation" do
            value(subject.("TEST")).must_equal(" -> TEST")
            value(subject.()).must_equal(" ...")
          end
        end
      end

      describe "GIVEN a block" do
        before do
          @puts_calls = []
          MuchStub.on_call($stdout, :puts) { |call| @puts_calls << call }
        end

        it "puts the expected header and footer banner Strings, "\
           "and returns the value from the block" do
          value(subject.call("TEST") { "TEST_BLOCK_RETURN_VALUE" }).must_equal(
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

    describe ".with_block" do
      subject { Say }

      describe "GIVEN no block" do
        it "raises ArgumentError" do
          value(-> { subject.with_block }).must_raise(ArgumentError)
        end
      end

      describe "GIVEN a block" do
        before do
          @puts_calls = []
          MuchStub.on_call($stdout, :puts) { |call| @puts_calls << call }
        end

        context "GIVEN no messages" do
          it "puts the expected header and footer banner Strings, "\
             "and returns the value from the block" do
            value(subject.with_block { "TEST_RESULT" }).
              must_equal("TEST_RESULT")

            # rubocop:disable Layout/LineLength
            value(@puts_calls[0].args).must_equal([
              "================================================================================"
            ])
            value(@puts_calls[1].args).must_equal([
              "= Done (0.0000s) ===============================================================",
              "\n"
            ])
            # rubocop:enable Layout/LineLength
          end
        end

        context "GIVEN a header message" do
          it "returns the expected header banner String" do
            subject.with_block(header: "TEST_HEADER") do nil end

            # rubocop:disable Layout/LineLength
            value(@puts_calls[0].args).must_equal([
              "= TEST_HEADER =================================================================="
            ])
            # rubocop:enable Layout/LineLength
          end
        end

        context "GIVEN a footer message" do
          it "returns the expected footer banner String" do
            subject.with_block(footer: "TEST_FOOTER") do nil end

            # rubocop:disable Layout/LineLength
            value(@puts_calls[1].args).must_equal([
              "= TEST_FOOTER (0.0000s) ========================================================",
              "\n"
            ])
            # rubocop:enable Layout/LineLength
          end
        end
      end
    end

    describe ".say_header" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        value(subject.header).must_equal(
          "================================================================================")
        value(@puts_call.args).must_equal([
          "================================================================================"
        ])
        # rubocop:enable Layout/LineLength
      end

      it "puts and returns the expected String, GIVEN a message" do
        # rubocop:disable Layout/LineLength
        value(subject.header("TEST")).must_equal(
          "= TEST =========================================================================")
        value(@puts_call.args).must_equal([
          "= TEST ========================================================================="
        ])
        # rubocop:enable Layout/LineLength
      end

      context "GIVEN an extra long String" do
        it "puts and returns the full String anyway, with minimal decoration" do
          # rubocop:disable Layout/LineLength
          value(subject.header("T" * 90)).must_equal(
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =")
          value(@puts_call.args).must_equal([
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ="
          ])
          # rubocop:enable Layout/LineLength
        end
      end
    end

    describe ".say_result" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN no message" do
        value(subject.result).must_equal(" ...")
        value(@puts_call.args).must_equal([" ..."])
      end

      it "puts and returns the expected String, GIVEN a message" do
        value(subject.result("TEST")).must_equal(" -> TEST")
        value(@puts_call.args).must_equal([" -> TEST"])
      end

      it "puts and returns the expected String, GIVEN a message and type" do
        value(subject.result("TEST", type: :info)).must_equal(" -- TEST")
        value(@puts_call.args).must_equal([" -- TEST"])
      end

      context "GIVEN an extra long message String" do
        it "puts and returns the full String" do
          # rubocop:disable Layout/LineLength
          value(subject.result("T" * 90)).must_equal(
            " -> TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT")
          value(@puts_call.args).must_equal([
            " -> TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"
          ])
          # rubocop:enable Layout/LineLength
        end
      end
    end

    describe ".say_footer" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        value(subject.footer).must_equal(
          "= Done =========================================================================\n\n")
        value(@puts_call.args).must_equal([
          "= Done =========================================================================",
          "\n"
        ])
        # rubocop:enable Layout/LineLength
      end

      it "puts and returns the expected String, GIVEN a message" do
        # rubocop:disable Layout/LineLength
        value(subject.footer("TEST")).must_equal(
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
          value(subject.footer("T" * 90)).must_equal(
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =\n\n")
          value(@puts_call.args).must_equal([
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =",
            "\n"
          ])
          # rubocop:enable Layout/LineLength
        end
      end
    end

    describe ".say_banner" do
      subject { Say }

      it "returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        value(subject.banner).must_equal(
          "================================================================================")
        # rubocop:enable Layout/LineLength
      end

      it "returns the expected String, GIVEN an empty message" do
        # rubocop:disable Layout/LineLength
        value(subject.banner("")).must_equal(
          "=  =============================================================================")
        # rubocop:enable Layout/LineLength
      end

      it "returns the expected String, GIVEN a short message" do
        # rubocop:disable Layout/LineLength
        value(subject.banner("TEST")).must_equal(
          "= TEST =========================================================================")
        # rubocop:enable Layout/LineLength
      end

      it "returns the expected String, GIVEN a long message" do
        # rubocop:disable Layout/LineLength
        value(subject.banner("T" * 90)).must_equal(
          "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =")
        # rubocop:enable Layout/LineLength
      end
    end

    describe ".say_message" do
      subject { Say }

      it "returns the expected String, GIVEN no message" do
        value(subject.message).must_equal(" ...")
      end

      it "returns the expected String, GIVEN a message" do
        value(subject.message("TEST")).must_equal(" -> TEST")
      end

      it "returns the expected String, GIVEN a type" do
        value(subject.message("TEST", type: :info)).must_equal(" -- TEST")
      end
    end

    describe ".write" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      context "GIVEN silent = false" do
        it "puts and returns the expected String, GIVEN a single message" do
          value(subject.write("TEST")).must_equal("TEST")
          value(@puts_call.args).must_equal(["TEST"])
        end

        it "puts and returns the expected String, GIVEN many messages" do
          value(subject.write("TEST 1", "TEST 2")).must_equal("TEST 1\nTEST 2")
          value(@puts_call.args).must_equal(["TEST 1", "TEST 2"])
        end
      end

      context "GIVEN silent = true" do
        it "returns the expected String, GIVEN a single message" do
          value(subject.write("TEST", silent: true)).must_equal("TEST")
          value(@puts_call).must_be_nil
        end

        it "returns the expected String, GIVEN more than one message" do
          value(subject.write("TEST 1", "TEST 2", silent: true)).must_equal(
            "TEST 1\nTEST 2")
          value(@puts_call).must_be_nil
        end
      end
    end

    describe "#say" do
      before do
        MuchStub.on_call(Say, :call) { |call| @say_call_call = call }
      end

      subject { Class.new { include Say }.new }

      it "forwards args and the given block to Say.call" do
        subject.say("TEST", :type) { "BLOCK" }
        value(@say_call_call.args).must_equal(["TEST", :type])
        value(@say_call_call.block).wont_be_nil
      end
    end

    describe "#say_with_block" do
      before do
        MuchStub.on_call(Say, :with_block) { |call|
          @say_with_block_call = call
        }
      end

      subject { Class.new { include Say }.new }

      it "forwards args and the given block to Say.with_block" do
        subject.say_with_block(header: "HEADER", footer: "FOOTER") { "BLOCK" }
        value(@say_with_block_call.kargs).must_equal(
          header: "HEADER", footer: "FOOTER")
        value(@say_with_block_call.block).wont_be_nil
      end
    end

    describe "#say_header" do
      before do
        MuchStub.on_call(Say, :header) { |call| @say_header_call = call }
      end

      subject { Class.new { include Say }.new }

      it "forwards all args to Say.header" do
        subject.say_header("TEST")
        value(@say_header_call.args).must_equal(["TEST"])
      end
    end

    describe "#say_result" do
      before do
        MuchStub.on_call(Say, :result) { |call| @say_result_call = call }
      end

      subject { Class.new { include Say }.new }

      it "forwards all args to Say.result" do
        subject.say_result("TEST")
        value(@say_result_call.args).must_equal(["TEST"])
      end
    end

    describe "#say_footer" do
      before do
        MuchStub.on_call(Say, :footer) { |call| @say_footer_call = call }
      end

      subject { Class.new { include Say }.new }

      it "forwards all args to Say.footer" do
        subject.say_footer("TEST")
        value(@say_footer_call.args).must_equal(["TEST"])
      end
    end

    describe "#say_banner" do
      before do
        MuchStub.on_call(Say, :banner) { |call| @say_banner_call = call }
      end

      subject { Class.new { include Say }.new }

      it "forwards all args to Say.banner" do
        subject.say_banner("TEST")
        value(@say_banner_call.args).must_equal(["TEST"])
      end
    end

    describe "#say_message" do
      before do
        MuchStub.on_call(Say, :message) { |call| @say_message_call = call }
      end

      subject { Class.new { include Say }.new }

      it "forwards all args to Say.message" do
        subject.say_message("TEST")
        value(@say_message_call.args).must_equal(["TEST"])
      end
    end
  end
end
