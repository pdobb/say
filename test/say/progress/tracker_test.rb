# frozen_string_literal: true

require "test_helper"

class Say::Progress::TrackerTest < Minitest::Spec
  describe "Say::Progress::Tracker" do
    describe "#initialize" do
      context "GIVEN no arguments" do
        subject { Say::Progress::Tracker.new }

        it "initializes the expected attribute values" do
          value(subject.interval).must_equal(1)
          value(subject.index).must_equal(0)
        end
      end

      context "GIVEN a castable Integer for `interval`" do
        subject { Say::Progress::Tracker.new(interval: "3") }

        it "sets the interval to the expected Integer" do
          value(subject.interval).must_equal(3)
        end
      end

      context "GIVEN a non-castable Integer for `interval`" do
        subject { Say::Progress::Tracker.new(interval: Object.new) }

        it "raises TypeError" do
          value(-> { subject.call }).must_raise(TypeError)
        end
      end

      context "GIVEN a castable Integer for `index`" do
        subject { Say::Progress::Tracker.new(index: "3") }

        it "sets the index to the expected Integer" do
          value(subject.index).must_equal(3)
        end
      end

      context "GIVEN a non-castable Integer for `index`" do
        subject { Say::Progress::Tracker.new(index: Object.new) }

        it "raises TypeError" do
          value(-> { subject.call }).must_raise(TypeError)
        end
      end
    end

    describe "call" do
      subject { Say::Progress::Tracker.new }

      it "yields an Interval object that points back to self" do
        subject.call do |interval|
          value(interval.tracker).must_equal(subject)
        end
      end
    end

    describe "#update" do
      subject { Say::Progress::Tracker.new }

      it "updates #index, GIVEN an Integer" do
        subject.update(9)
        value(subject.index).must_equal(9)
      end

      it "updates #index, GIVEN a castable Integer type" do
        subject.update("9")
        value(subject.index).must_equal(9)
      end

      it "raises TypeError, GIVEN a non-castable Integer type" do
        value(-> {
          subject.update(Object.new)
        }).must_raise(TypeError)
      end

      it "returns self" do
        value(subject.update(9)).must_equal(subject)
      end
    end

    describe "#increment" do
      subject { Say::Progress::Tracker.new }

      it "increments #index" do
        subject.increment
        value(subject.index).must_equal(1)
      end

      it "returns self" do
        value(subject.increment).must_equal(subject)
      end
    end

    describe "#tick?" do
      subject { Say::Progress::Tracker.new(interval: 5) }

      it "returns false, GIVEN index = 0" do
        value(subject.tick?).must_equal(false)
      end

      it "returns true, GIVEN #index is a multiple of #interval" do
        subject.update(5)
        value(subject.tick?).must_equal(true)
      end

      it "returns false, GIVEN #index is not a multiple of #interval" do
        subject.update(1)
        value(subject.tick?).must_equal(false)
      end
    end
  end
end
