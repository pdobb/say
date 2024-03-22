# frozen_string_literal: true

require "test_helper"

class SayTest < Minitest::Spec
  describe "Say" do
    describe "::MAX_COLUMNS" do
      it "returns the expected Integer" do
        value(Say::MAX_COLUMNS).must_equal(80)
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
            value(@puts_call.args.first.to_s).must_equal(" ...")
          end
        end

        context "GIVEN a message" do
          it "puts and returns the expected formatted message String" do
            value(subject.call("TEST")).must_equal(" -> TEST")
            value(@puts_call.args.first.to_s).must_equal(" -> TEST")
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
            "= TEST =========================================================================",
          ])
          value(@puts_calls[1].args).must_equal([
            "= Done (0.0000s) ===============================================================",
          ])
          # rubocop:enable Layout/LineLength
        end
      end
    end

    describe "Say.<type> convenience methods" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      describe ".debug" do
        it "returns the expected String, GIVEN text" do
          value(Say.debug("TEST")).must_equal(" >> TEST")
        end
      end

      describe ".error" do
        it "returns the expected String, GIVEN text" do
          value(Say.error("TEST")).must_equal(" ** TEST")
        end
      end

      describe ".info" do
        it "returns the expected String, GIVEN text" do
          value(Say.info("TEST")).must_equal(" -- TEST")
        end
      end

      describe ".success" do
        it "returns the expected String, GIVEN text" do
          value(Say.success("TEST")).must_equal(" -> TEST")
        end
      end

      describe ".warn" do
        it "returns the expected String, GIVEN text" do
          value(Say.warn("TEST")).must_equal(" !¡ TEST")
        end
      end
    end

    describe ".line" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN no message" do
        value(subject.line).must_equal(" ...")
        value(@puts_call.args.first.to_s).must_equal(" ...")
      end

      it "puts and returns the expected String, GIVEN a message" do
        value(subject.line("TEST")).must_equal(" -> TEST")
        value(@puts_call.args.first.to_s).must_equal(" -> TEST")
      end

      it "puts and returns the expected String, GIVEN a message and type" do
        value(subject.line("TEST", type: :info)).must_equal(" -- TEST")
        value(@puts_call.args.first.to_s).must_equal(" -- TEST")
      end

      context "GIVEN an extra long message String" do
        it "puts and returns the full String" do
          # rubocop:disable Layout/LineLength
          expected_result =
            " -> TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"
          # rubocop:enable Layout/LineLength
          value(subject.line("T" * 90)).must_equal(expected_result)
          value(@puts_call.args.first.to_s).must_equal(expected_result)
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
              "================================================================================",
            ])
            value(@puts_calls[1].args).must_equal([
              "= Done (0.0000s) ===============================================================",
            ])
            # rubocop:enable Layout/LineLength
          end
        end

        context "GIVEN a header message" do
          it "returns the expected header banner String" do
            subject.with_block(header: "TEST_HEADER") { nil }

            # rubocop:disable Layout/LineLength
            value(@puts_calls[0].args).must_equal([
              "= TEST_HEADER ==================================================================",
            ])
            # rubocop:enable Layout/LineLength
          end
        end

        context "GIVEN a footer message" do
          it "returns the expected footer banner String" do
            subject.with_block(footer: "TEST_FOOTER") { nil }

            # rubocop:disable Layout/LineLength
            value(@puts_calls[1].args).must_equal([
              "= TEST_FOOTER (0.0000s) ========================================================",
            ])
            # rubocop:enable Layout/LineLength
          end
        end
      end
    end

    describe ".header" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        expected_result =
          "================================================================================"
        # rubocop:enable Layout/LineLength
        value(subject.header).must_equal(expected_result)
        value(@puts_call.args).must_equal([expected_result])
      end

      it "puts and returns the expected String, GIVEN a message" do
        # rubocop:disable Layout/LineLength
        expected_result =
          "= TEST ========================================================================="
        # rubocop:enable Layout/LineLength
        value(subject.header("TEST")).must_equal(expected_result)
        value(@puts_call.args).must_equal([expected_result])
      end

      context "GIVEN an extra long String" do
        it "puts and returns the full String anyway, with minimal decoration" do
          # rubocop:disable Layout/LineLength
          expected_result =
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ="
          # rubocop:enable Layout/LineLength
          value(subject.header("T" * 90)).must_equal(expected_result)
          value(@puts_call.args).must_equal([expected_result])
        end
      end
    end

    describe ".footer" do
      before do
        @puts_calls = []
        MuchStub.on_call($stdout, :puts) { |call| @puts_calls << call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        expected_result =
          "= Done ========================================================================="
        # rubocop:enable Layout/LineLength
        value(subject.footer).must_equal(expected_result)
        value(@puts_calls.map(&:args).tap(&:flatten!)).must_equal(
          [expected_result, "\n"])
      end

      it "puts and returns the expected String, GIVEN a message" do
        # rubocop:disable Layout/LineLength
        expected_result =
          "= TEST ========================================================================="
        # rubocop:enable Layout/LineLength
        value(subject.footer("TEST")).must_equal(expected_result)
        value(@puts_calls.map(&:args).tap(&:flatten!)).must_equal(
          [expected_result, "\n"])
      end

      context "GIVEN an extra long String" do
        it "puts and returns the full String anyway, with minimal decoration" do
          # rubocop:disable Layout/LineLength
          expected_result =
            "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ="
          # rubocop:enable Layout/LineLength
          value(subject.footer("T" * 90)).must_equal(expected_result)
          value(@puts_calls.map(&:args).tap(&:flatten!)).must_equal(
            [expected_result, "\n"])
        end
      end
    end

    describe ".banner" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        expected_result =
          "================================================================================"
        # rubocop:enable Layout/LineLength
        value(subject.banner).must_equal(expected_result)
        value(@puts_call.args).must_equal([expected_result])
      end

      it "returns the expected String, GIVEN an empty message" do
        # rubocop:disable Layout/LineLength
        expected_result =
          "=  ============================================================================="
        # rubocop:enable Layout/LineLength
        value(subject.banner("")).must_equal(expected_result)
        value(@puts_call.args).must_equal([expected_result])
      end

      it "returns the expected String, GIVEN a short message" do
        # rubocop:disable Layout/LineLength
        expected_result =
          "= TEST ========================================================================="
        # rubocop:enable Layout/LineLength
        value(subject.banner("TEST")).must_equal(expected_result)
        value(@puts_call.args).must_equal([expected_result])
      end

      it "returns the expected String, GIVEN a long message" do
        # rubocop:disable Layout/LineLength
        expected_result =
          "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ="
        # rubocop:enable Layout/LineLength
        value(subject.banner("T" * 90)).must_equal(expected_result)
        value(@puts_call.args).must_equal([expected_result])
      end
    end

    describe ".section" do
      before do
        @puts_calls = []
        MuchStub.on_call($stdout, :puts) { |call| @puts_calls << call }
      end

      subject { Say }

      it "returns the expected String, GIVEN no message" do
        # rubocop:disable Layout/LineLength
        expected_result = [
          "================================================================================",
          "================================================================================",
          "================================================================================",
        ]
        # rubocop:enable Layout/LineLength
        value(subject.section).must_equal(expected_result)
        value(@puts_calls.map(&:args).tap(&:flatten!)).must_equal(
          expected_result + ["\n"])
      end

      it "returns the expected String, GIVEN an empty message" do
        # rubocop:disable Layout/LineLength
        expected_result = [
          "================================================================================",
          "=  =============================================================================",
          "================================================================================",
        ]
        # rubocop:enable Layout/LineLength
        value(subject.section("")).must_equal(expected_result)
        value(@puts_calls.map(&:args).tap(&:flatten!)).must_equal(
          expected_result + ["\n"])
      end

      it "returns the expected String, GIVEN a short message" do
        # rubocop:disable Layout/LineLength
        expected_result = [
          "================================================================================",
          "= TEST =========================================================================",
          "================================================================================",
        ]
        # rubocop:enable Layout/LineLength
        value(subject.section("TEST")).must_equal(expected_result)
        value(@puts_calls.map(&:args).tap(&:flatten!)).must_equal(
          expected_result + ["\n"])
      end

      it "returns the expected String, GIVEN a long message" do
        # rubocop:disable Layout/LineLength
        expected_result = [
          "==============================================================================================",
          "= TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT =",
          "==============================================================================================",
        ]
        # rubocop:enable Layout/LineLength
        value(subject.section("T" * 90)).must_equal(expected_result)
        value(@puts_calls.map(&:args).tap(&:flatten!)).must_equal(
          expected_result + ["\n"])
      end
    end

    describe ".progress" do
      before do
        MuchStub.tap_on_call(Say::Progress::Tracker, :new) { |object, call|
          @progress_tracker_new_call = call

          MuchStub.on_call(object, :call) { |inner_call|
            @progress_tracker_object_call_call = inner_call
          }
        }

        MuchStub.tap_on_call(Say, :with_block) { |call|
          @say_with_bock_call = call
        }
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "forwards all args except message to Say::Progress::Tracker.new" do
        subject.progress("TEST", interval: 10)
        value(@progress_tracker_new_call.args).must_equal([{ interval: 10 }])
      end

      context "GIVEN a block" do
        it "calls Say.with_block and "\
           "passes the block to Say::Progress::Tracker#call" do
          subject.progress("TEST", interval: 10) { "TEST_BLOCK" }
          value(@say_with_bock_call).wont_be_nil
          value(@progress_tracker_object_call_call.block.call).must_equal(
            "TEST_BLOCK")
        end
      end

      context "GIVEN no block" do
        it "calls Say.with_block and "\
           "passes nil to Say::Progress::Tracker#call" do
          subject.progress("TEST", interval: 10)
          value(@say_with_bock_call).wont_be_nil
          value(@progress_tracker_object_call_call.block).must_be_nil
        end
      end
    end

    describe ".progress_line" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN no index" do
        Timecop.freeze(Say::Time.test_sample) do
          value(subject.progress_line).must_equal(
            "[12340506123456]  ...")
          value(@puts_call.args).must_equal(["[12340506123456]  ..."])
        end
      end

      it "puts and returns the expected String, GIVEN no message" do
        Timecop.freeze(Say::Time.test_sample) do
          value(subject.progress_line(index: 9)).must_equal(
            "[12340506123456]  ... (i=9)")
          value(@puts_call.args).must_equal(["[12340506123456]  ... (i=9)"])
        end
      end

      it "puts and returns the expected String, GIVEN a message" do
        Timecop.freeze(Say::Time.test_sample) do
          value(subject.progress_line("TEST", index: 9)).must_equal(
            "[12340506123456]  -- TEST (i=9)")
          value(@puts_call.args).must_equal(["[12340506123456]  -- TEST (i=9)"])
        end
      end

      it "puts and returns the expected String, GIVEN a message and type" do
        Timecop.freeze(Say::Time.test_sample) do
          value(subject.progress_line("TEST", :success, index: 9)).
            must_match("[12340506123456]  -> TEST (i=9)")
          value(@puts_call.args).must_equal(["[12340506123456]  -> TEST (i=9)"])
        end
      end
    end

    describe ".write" do
      before do
        MuchStub.on_call($stdout, :puts) { |call| @puts_call = call }
      end

      subject { Say }

      it "puts and returns the expected String, GIVEN a single message" do
        value(subject.write("TEST")).must_equal("TEST")
        value(@puts_call.args).must_equal(["TEST"])
      end

      it "puts and returns the expected String, GIVEN many messages" do
        value(subject.write("TEST 1", "TEST 2")).must_equal("TEST 1\nTEST 2")
        value(@puts_call.args).must_equal(["TEST 1", "TEST 2"])
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

    describe "#say_line" do
      before do
        MuchStub.on_call(Say, :line) { |call| @say_line_call = call }
      end

      subject { Class.new { include Say }.new }

      it "forwards all args to Say.line" do
        subject.say_line("TEST")
        value(@say_line_call.args).must_equal(["TEST"])
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

    describe "#say_section" do
      before do
        MuchStub.on_call(Say, :section) { |call| @say_section_call = call }
      end

      subject { Class.new { include Say }.new }

      it "forwards all args to Say.section" do
        subject.say_section("TEST")
        value(@say_section_call.args).must_equal(["TEST"])
      end
    end

    describe "#say_progress" do
      before do
        MuchStub.on_call(Say, :progress) { |call|
          @say_progress_call = call
        }
      end

      subject { Class.new { include Say }.new }

      it "forwards all args to Say.progress" do
        subject.say_progress("TEST", index: 9, interval: 5)
        value(@say_progress_call.args).must_equal(
          ["TEST", { index: 9, interval: 5 }])
      end
    end

    describe "#say_progress_line" do
      before do
        MuchStub.on_call(Say, :progress_line) { |call|
          @say_progress_line_call = call
        }
      end

      subject { Class.new { include Say }.new }

      it "forwards all args to Say.progress_line" do
        subject.say_progress_line("TEST", index: 9)
        value(@say_progress_line_call.args).must_equal(
          ["TEST", { index: 9 }])
      end
    end
  end
end
