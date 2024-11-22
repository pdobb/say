# frozen_string_literal: true

require "test_helper"

class Say::TimeTest < Minitest::Spec
  describe "Say::Time" do
    describe ".timestamp" do
      before do
        Timecop.freeze(Say::Time.test_sample)
      end

      after do
        Timecop.return
      end

      subject { Say::Time }

      context "GIVEN no time, nor format" do
        it "returns the expected String" do
          _(subject.timestamp).must_equal("12340506123456")
        end
      end

      context "GIVEN a time" do
        it "returns the expected String" do
          _(subject.timestamp(Time.new(1234, 5, 6, 12, 34, 56))).must_equal(
            "12340506123456")
        end
      end

      context "GIVEN a format Symbol" do
        it "returns the expected String" do
          _(subject.timestamp(format: :long)).must_match(
            %r{05/06/1234 12:34:56 \w{3}})
        end
      end

      context "GIVEN a format String" do
        it "returns the expected String" do
          _(subject.timestamp(format: "%Y%m%d%H%M%S")).must_equal(
            "12340506123456")
        end
      end
    end
  end
end
