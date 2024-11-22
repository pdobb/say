# frozen_string_literal: true

require "test_helper"

class Say::MessageTest < Minitest::Spec
  describe "Say::Message" do
    describe "::TYPES" do
      it "defines the expected type keys" do
        _(Say::Message::TYPES.keys).must_equal(
          %i[debug error info success warn])
      end

      it "defaults to :success" do
        _(Say::Message::TYPES.default).must_equal(
          Say::Message::TYPES[:success])
      end

      it "has an immutable default value" do
        assert_raises(FrozenError) do
          Say::Message::TYPES[:unknown_type] << "NOPE"
        end
      end
    end

    describe "#text" do
      context "GIVEN no text" do
        subject { Say::Message.new }

        it "returns nil" do
          _(subject.text).must_be_nil
        end
      end

      context "GIVEN text" do
        subject { Say::Message.new("TEST") }

        it "returns the expected String" do
          _(subject.text).must_equal("TEST")
        end
      end
    end

    describe "#type" do
      context "GIVEN no type" do
        subject { Say::Message.new("TEST") }

        it "returns the expected String" do
          _(subject.type).must_equal(:success)
        end
      end

      context "GIVEN a type" do
        subject { Say::Message.new("TEST", type: :error) }

        it "returns the expected String" do
          _(subject.type).must_equal(:error)
        end
      end

      context "GIVEN type = nil" do
        subject { Say::Message.new("TEST", type: nil) }

        it "returns the expected String" do
          _(subject.type).must_equal(:success)
        end
      end
    end

    describe "#to_s" do
      context "GIVEN no text" do
        subject { Say::Message.new }

        it "returns the expected String" do
          _(subject.to_s).must_equal(" ...")
        end
      end

      context "GIVEN text" do
        context "GIVEN no type" do
          subject { Say::Message.new("TEST") }

          it "returns the expected String" do
            _(subject.to_s).must_equal(" -> TEST")
          end
        end

        context "GIVEN a type" do
          subject { Say::Message.new("TEST", type: :error) }

          it "returns the expected String" do
            _(subject.to_s).must_equal(" ** TEST")
          end
        end
      end
    end
  end
end
