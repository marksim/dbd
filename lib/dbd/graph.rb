require 'csv'

module Dbd

  ##
  # The Graph stores the Facts and ProvenanceFacts in an in-memory
  # collection structure.
  class Graph

    include Fact::Collection

    ##
    # Add a Fact or Resource or any set recursively.
    #
    # This will add a time_stamp to the Facts.
    def <<(recursive_fact_collection)
      loop_recursively(recursive_fact_collection) do |fact|
        enforce_strictly_monotonic_time(fact)
        super(fact)
      end
    end

    ##
    # Export the graph to a CSV string
    #
    # @return [String] comma separated string with double quoted cells
    def to_CSV
      CSV.generate(force_quotes: true) do |csv|
        @internal_collection.each do |fact|
          csv << fact.values
        end
      end.encode("utf-8")
    end

  private

    ##
    # Setting a strictly monotonically increasing time_stamp (if not yet set).
    # The time_stamp also has some randomness (1 .. 999 ns) to reduce the
    # chance on collisions when merging fact streams from different sources.
    def enforce_strictly_monotonic_time(fact)
      fact.time_stamp = TimeStamp.new(larger_than: newest_time_stamp) unless fact.time_stamp
    end

    def loop_recursively(recursive_collection, &block)
      Array(recursive_collection).each do |fact_or_collection|
        further_recursion_or_stop(fact_or_collection, &block)
      end
    end

    def further_recursion_or_stop(fact_or_collection, &block)
      if fact_or_collection.respond_to?(:each)
        loop_recursively(fact_or_collection, &block)
      else
        yield(fact_or_collection)
      end
    end

  end
end
