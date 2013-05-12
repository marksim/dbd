require 'dbd/helpers/ordered_set_collection'

module Dbd
  class Fact
    class Collection

      include Helpers::OrderedSetCollection

      def initialize
        super
        @hash_by_subject = Hash.new { |h, k| h[k] = [] }
        @used_provenance_subjects = {}
      end

      def newest_time_stamp
        newest_entry = @internal_collection.last
        newest_entry && newest_entry.time_stamp
      end

      def oldest_time_stamp
        oldest_entry = @internal_collection.first
        oldest_entry && oldest_entry.time_stamp
      end

      ##
      # This is the central method of Fact::Collection
      #
      # @param [Fact] element the element that is added to the collection
      #
      # @return [self] for chaining
      #
      # Validates that added fact is valid.
      #
      # Validates that added fact is newer.
      #
      # Validates that subject was never used as provenance_subject [A].
      #
      # Adds the element and return the index in the collection.
      #
      # Store this index in the hash_by_subject.
      #
      # Mark the element in the list of used provenance_subjects (for [A]).
      def <<(element)
        raise FactError unless element.valid?
        raise OutOfOrderError if (self.newest_time_stamp && element.time_stamp <= self.newest_time_stamp)
        raise OutOfOrderError if (@used_provenance_subjects[element.subject])
        index = Helpers::OrderedSetCollection.add_and_return_index(element, @internal_collection)
        @hash_by_subject[element.subject] << index
        element.update_used_provenance_subjects(@used_provenance_subjects)
        self
      end

      def by_subject(fact_subject)
        @hash_by_subject[fact_subject].map{ |index| @internal_collection[index]}
      end

    end
  end
end
