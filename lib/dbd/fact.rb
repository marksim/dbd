require 'dbd/fact/collection'
require 'dbd/fact/subject'
require 'dbd/fact/id'

module Dbd
  class Fact

    def self.attributes
      [:id,
       :time_stamp,
       :provenance_fact_subject,
       :subject,
       :predicate,
       :object]
    end

    attributes.each do |attribute|
      attr_reader attribute
    end

    def self.new_subject
      Subject.new
    end

    def self.new_id
      ID.new
    end

    def initialize(provenance_fact_subject, subject, predicate, object)
      @id = self.class.new_id
      @provenance_fact_subject = provenance_fact_subject
      @subject = subject
      @predicate = predicate
      @object = object
    end

    def values
      self.class.attributes.map{ |attribute| self.send(attribute) }
    end

    def update_provenance_fact_subjects(h)
      # using a provenance_fact_subject sets the key
      h[provenance_fact_subject] = true
    end

  end
end
