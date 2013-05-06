module Dbd
  module Fact
    class Collection

      class OutOfOrderError < StandardError
      end

      include Helpers::ArrayCollection

      def initialize
        super
        @hash_by_subject = Hash.new { |h, k| h[k] = [] }
      end

      def newest_time_stamp
        newest_entry = @internal_collection.last
        newest_entry && newest_entry.time_stamp
      end

      def oldest_time_stamp
        oldest_entry = @internal_collection.first
        oldest_entry && oldest_entry.time_stamp
      end

      def <<(element)
        raise OutOfOrderError if (self.newest_time_stamp && element.time_stamp <= self.newest_time_stamp)
        super.tap do |index|
          @hash_by_subject[element.subject] << index
        end
      end

      def by_subject(fact_subject)
        @hash_by_subject[fact_subject].map{ |index| @internal_collection[index]}
      end

    end
  end
end
