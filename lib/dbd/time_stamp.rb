module Dbd

  ##
  # TimeStamp
  #
  # Each Fact has a time_stamp with a granularity of 1 ns. The small
  # granularity is essential to allow enough "density" of Facts in a
  # large fact stream. Since all Facts need to have a strictly
  # monotonically increasing time_stamp, this causes a limitation of
  # max 1_000_000_000 Facts per second in a fact stream.
  #
  # A second reason for a fine grained granularity of the time_stamp
  # is to reduce the chance (but not to zero) for collisions between
  # Facts when 2 (or more) fact streams with overlapping time ranges
  # need to be merged. But, collisions are always possible and need
  # to be handled (since this can be expensive, we need to avoid them).
  #
  # A practicaly problem with calculating a "randomized" time_stamp is
  # that the system reports a Wall clock with a granularity of 1 us on
  # MRI Ruby and only 1 ms on JRuby (see JSR 310). To solve this problem,
  # some nifty tricks are needed to create more "randomized" time_stamps,
  # while still guaranteeing, the strictly monotonic increase in an
  # upredictable fact stream.
  #
  # Performance measurements show a typical 30 - 60 us delay between the
  # consecutive created facts (on MRI and JRuby), so a randomization of
  # e.g. 1 - 999 ns should not cause fundamental problems for the density
  # of the facts (even if computers speed up a factor of 30 or an
  # implementation in a faster language). Still this is an ad-hoc
  # optimization at creation time and can be optimized without breaking
  # the specification of the fact stream.
  #
  # A time_stamp does not need to represent the exact time of the
  # creation of the fact, it only has to increase strictly monotic
  # in a fact stream.
  class TimeStamp

    def initialize
      @time = Time.now.utc
    end

    def self.to_s_regexp
      /\d{4}-\d\d-\d\d \d\d:\d\d:\d\d\.\d{9} UTC/
    end

    def to_s
      @time.strftime('%F %T.%N %Z')
    end

  end
end
