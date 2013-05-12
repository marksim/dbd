require 'dbd/fact/collection'
require 'dbd/fact/subject'
require 'dbd/fact/id'

module Dbd

  ##
  # Basic Fact of knowledge.
  #
  # The database is built as an ordered sequence of facts, the "fact stream".
  #
  # This is somewhat similar to a "triple" in the RDF (Resource Description
  # Framework) concept, but with different and extended functionality.
  #
  # Each basic fact has:
  # * a unique and invariant *id* (a uuid)
  #
  #   To allow referencing back to it (e.g. to invalidate it later in the fact stream).
  #
  # * a *time_stamp*  (time with nanosecond granularity)
  #
  #   To allow verifying that the order in the fact stream is correct.
  #
  #   A time_stamp does not need to represent the exact time of the
  #   creation of the fact, but it has to increase in strictly monotic
  #   order in the fact stream.
  #
  # * a *provenance_subject* (a uuid)
  #
  #   The subject of the ProvenanceResource (a set of ProvenanceFacts with
  #   the same subject) about this fact. Each Fact, points *back* to a
  #   ProvenanceResource (the ProvenanceResource must have been fully
  #   defined, earlier in the fact stream).
  #
  # * a *subject* (a uuid)
  #
  #   "About which Resource is this fact?".
  #
  #   Similar to the subject of an  RDF triple, except that this subject is not
  #   a URI, but an abstract uuid (that is world-wide unique and invariant).
  #
  #   Links to "real-world" URI's and URL's can be added later as separate facts
  #   (this also allows linking multiple "real-world" URI's to a single Resource).
  #
  # * a *predicate* (a string)
  #
  #   "Which property of the resource are we describing?".
  #
  #   Currently this is a string, but I suggest modeling this similar to predicate
  #   in RDF. Probably more detailed modeling using RDF predicate will follow.
  #
  # * an *object* (a string)
  #
  #   "What is the value of the property of the resource we are describing?".
  #
  #   Currently this is a string, but I suggest modeling this similar to object
  #   in RDF. Probably more detailed modeling using RDF object will follow.
  class Fact

    ##
    # @return [Array] The 6 attributes of a Fact.
    def self.attributes
      [:id,
       :time_stamp,
       :provenance_subject,
       :subject,
       :predicate,
       :object]
    end

    attributes.each do |attribute|
      attr_reader attribute
    end

    ##
    # @return [Subject] A new random subject.
    def self.new_subject
      Subject.new
    end

    ##
    # @return [ID] A new random id.
    def self.new_id
      ID.new
    end

    ##
    # Builds a new Fact.
    #
    # @param [Hash{Symbol => Object}] options
    # @option options [#to_s] :predicate Required : the predicate for this Fact
    # @option options [#to_s] :object Required :  the object for this Fact (required)
    # @option options [Subject] :provenance_subject (nil) Optional: the subject of the provenance(resource|fact)
    # @option options [Subject] :subject (nil) Optional: the subject for this Fact
    def initialize(options)
      @id = self.class.new_id
      @provenance_subject = options[:provenance_subject]
      @subject = options[:subject]
      @predicate = options[:predicate]
      @object = options[:object]
      raise ArgumentError, "predicate cannot be nil" if predicate.nil?
      raise ArgumentError, "object cannot be nil" if object.nil?
    end

    ##
    # @return [Array] The 6 values of a Fact.
    def values
      self.class.attributes.map{ |attribute| self.send(attribute) }
    end

    ##
    # Executes the required update in used_provenance_subjects.
    #
    # For a Fact, pointing to a ProvenanceResource in it's provenance_subject,
    # marks this provenance_subject in the "used_provenance_subjects" hash that
    # is passed in as an argument (DCI). This will avoid further changes to the
    # ProvenanceResource with this provenance_subject.
    #
    # This is overridden in the ProvenanceFact, since only relevant for a Fact.
    def update_used_provenance_subjects(h)
      # using a provenance_subject sets the key
      h[provenance_subject] = true
    end

    ##
    # Checks if a fact is valid for storing in the graph.
    #
    # @return [#true?] not nil if valid
    def valid?
      # id not validated, is set automatically
      # predicate not validated, is validated in initialize
      # object not validated, is validated in initialize
      provenance_subject_valid?(provenance_subject) &&
      subject
    end

    ##
    # Validates the presence or absence of provenance_subject.
    #
    # Here, in (base) Fact, provenance_subject must be present
    # In the derived ProvenanceFact it must not be present.
    # This is how the difference is encoded between Fact and
    # ProvenanceFact in the fact stream.
    # @param [#nil?] provenance_subject
    # Return [Boolean]
    def provenance_subject_valid?(provenance_subject)
      provenance_subject
    end

    ##
    # Builds duplicate with the subject set.
    #
    # @param [Subject] subject_arg
    # @return [Fact] the duplicate fact
    def dup_with_subject(subject_arg)
      self.class.new(
       provenance_subject: provenance_subject,
       subject: subject_arg, # from arg
       predicate: predicate,
       object: object)
    end

    ##
    # Builds duplicate with the provenance_subject set.
    #
    # @param [Subject] provenance_subject_arg
    # @return [Fact] the duplicate fact
    def dup_with_provenance_subject(provenance_subject_arg)
      self.class.new(
       provenance_subject: provenance_subject_arg, # from arg
       subject: subject,
       predicate: predicate,
       object: object)
    end

  end
end
