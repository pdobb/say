# frozen_string_literal: true

require "test_helper"

class Say::Progress::IntervalTest < Minitest::Spec
  describe "Say::Progress::Interval" do
    describe "#initialize" do
      context "GIVEN no arguments" do
        subject { Say::Progress::Interval.new(tracker: "TEST_TRACKER") }

        it "initializes the expected attribute values" do
          _(subject.tracker).must_equal("TEST_TRACKER")
        end
      end
    end

    describe "#say" do
      subject {
        Say::Progress::Interval.new(
          tracker: Say::Progress::Tracker.new(interval: 5))
      }

      context "GIVEN an on-interval tick" do
        before do
          subject.update(current_index)
        end

        let(:current_index) { 5 }

        context "GIVEN a block" do
          before do
            MuchStub.on_call(Say, :progress) { |call|
              @say_progress_call = call
            }
          end

          it "calls Say.progress with the expected args and block" do
            result = subject.say("TEST") { "TEST_BLOCK" }

            _(result).wont_be_nil
            _(@say_progress_call.args).must_equal(
              ["TEST", { index: current_index }])
            _(@say_progress_call.block.call).must_equal("TEST_BLOCK")
          end
        end

        context "GIVEN no block" do
          before do
            MuchStub.on_call(Say, :progress_line) { |call|
              @say_call_call = call
            }
          end

          it "calls Say.progress_line with the expected args" do
            result = subject.say("TEST", :debug)

            _(result).wont_be_nil
            _(@say_call_call.args).must_equal(["TEST", :debug, { index: 5 }])
          end
        end
      end

      context "GIVEN an off-interval tick" do
        it "calls the block, GIVEN a block" do
          _(subject.say("TEST") { "TEST_BLOCK" }).must_equal("TEST_BLOCK")
        end

        it "returns nil, GIVEN no block" do
          _(subject.say("TEST")).must_be_nil
        end
      end
    end

    describe "#update" do
      subject {
        Say::Progress::Interval.new(
          tracker: Say::Progress::Tracker.new)
      }

      it "increments tracker.index, GIVEN no arg" do
        _(subject.tracker.index).must_equal(0)
        subject.update
        _(subject.tracker.index).must_equal(1)
      end

      it "sets tracker.index, GIVEN an Integer" do
        _(subject.tracker.index).must_equal(0)
        subject.update(2)
        _(subject.tracker.index).must_equal(2)
      end

      it "raises TypeError, GIVEN a non-castable Integer" do
        _(-> {
          subject.update(Object.new)
        }).must_raise(TypeError)
      end

      it "returns self" do
        _(subject.update).must_equal(subject)
      end
    end
  end
end
