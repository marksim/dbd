module Factories
  module Fact

    def self.subject
      ::Dbd::Fact.new_subject
    end

    def self.fact_1(provenance_fact_subject = nil)
      ::Dbd::Fact.new(
        provenance_fact_subject,
        nil,
        "http://example.org/test/name",
        "Gandhi")
    end

    def self.fact_2_with_subject(provenance_fact_subject = nil)
      ::Dbd::Fact.new(
        provenance_fact_subject,
        subject,
        "http://example.org/test/name",
        "Mandela")
    end

    def self.fact_3(provenance_fact_subject = nil)
      ::Dbd::Fact.new(
        provenance_fact_subject,
        nil,
        "http://example.org/test/name",
        "King")
    end

    module Collection
      def self.fact_1_2(provenance_fact_subject = nil)
        ::Dbd::Fact::Collection.new.tap do |facts|
          facts << Fact.fact_1(provenance_fact_subject)
          facts << Fact.fact_2_with_subject(provenance_fact_subject)
        end
      end

      def self.provenance_facts(subject = nil)
        ::Dbd::Fact::Collection.new.tap do |provenance_facts|
          provenance_facts << ProvenanceFact.context(subject)
          provenance_facts << ProvenanceFact.created_by(subject)
          provenance_facts << ProvenanceFact.original_source(subject)
        end
      end
    end
  end
end
