# frozen_string_literal: true

# Say::Progress::Tracker keeps track of current progress for Interval trackers,
# like {Say::Progress::Interval}.
#
# @see Say::Progress::Interval
class Say::Progress::Tracker
  DEFAULT_INTERVAL = 1

  attr_reader :interval,
              :index

  def initialize(interval: DEFAULT_INTERVAL, index: 0)
    @interval = Integer(interval)
    @index = Integer(index)
  end

  # Calls the provided block, passing a new instance of Say::Progress::Interval
  # with `self` as the current tracker. This allows the block to perform
  # operations or actions using the Interval instance.
  #
  # @yieldparam interval [Say::Progress::Interval]
  def call
    interval = Say::Progress::Interval.new(tracker: self)
    yield(interval)
  end

  # @return [self] self, after updating the index.
  def update(index)
    @index = Integer(index)
    self
  end

  # @return [self] self, after incrementing the index.
  def increment
    @index += 1
    self
  end

  # Checks of the current index is non-zero and on-Interval. i.e. Given
  # interval = X, if the current index is not 0 and is a multiple of X, then we
  # are on-Interval.
  #
  # @return [Boolean] Returns true if the current index is non-zero and is a
  #   multiple of the interval; otherwise, false.
  def tick?
    return false if index.zero?

    (index % interval).zero?
  end

  # rubocop:disable all
  # :nocov:

  # Usage: Say::Progress::Tracker.test;
  # @!visibility private
  def self.test
    Say.("Say::Progress::Tracker.test") do
      i1 = Say::Progress::Tracker.new
      i2 = Say::Progress::Tracker.new(interval: 2)

      results = [
        # Interval: 1
        i1.index,
        i1.tick?,
        i1.update(1).tick?,
        # Interval: 2
        i2.interval,
        i2.tick?,
        i2.update(1).tick?,
        i2.update(2).tick?,
      ]

      expected_results = [
        # Interval 1
        0,
        false,
        true,
        # Interval 2
        2,
        false,
        false,
        true,
      ]

      if results == expected_results
        ap(["✅", results])
      else
        ap(["❌", { "Got:" => results, "Expected:" => expected_results }])
      end
    end
  end

  # :nocov:
  # rubocop:enable all
end
