require 'spec_helper'

module Dbd
  class Fact
    describe Collection do

      let(:context_subject_1) { Fact.factory.new_subject }
      let(:context_subject_2) { Fact.factory.new_subject }

      let(:context_visibility) { TestFactories::Context.visibility(context_subject_1) }
      let(:context_created_by) { TestFactories::Context.created_by(context_subject_1) }
      let(:context_original_source) { TestFactories::Context.original_source(context_subject_2) }

      let(:fact_1) { TestFactories::Fact.fact_1(context_subject_1) }
      let(:fact_2_with_subject) { TestFactories::Fact.fact_2_with_subject(context_subject_1) }
      let(:fact_3_with_subject) { TestFactories::Fact.fact_3_with_subject(context_subject_1) }

      let(:fact_2_3) { TestFactories::Fact::Collection.fact_2_3(context_subject_1) }
      let(:contexts) { TestFactories::Fact::Collection.contexts(context_subject_1) }

      let(:subject) do
        Object.new.tap do |object_with_Fact_Collection|
          object_with_Fact_Collection.extend(described_class)
          object_with_Fact_Collection.send(:initialize)
        end
      end

      describe '.new : ' do
        it 'the collection is not an array' do
          subject.should_not be_a(Array)
        end

        it 'the collection has Enumerable methods' do
          subject.map #should_not raise_exception
        end
      end

      describe '.methods : ' do

        describe '#<< : ' do
          it 'adding a fact works' do
            subject << fact_2_with_subject
            subject.size.should == 1
          end

          it 'adding a context works' do
            subject << context_visibility
            subject.size.should == 1
          end

          it 'returns self to allow chaining' do
            (subject << context_visibility).should == subject
          end
        end

        it '#first should be a Fact' do
          subject << fact_2_with_subject
          subject.first.should be_a(Fact)
        end

        it 'other functions (e.g. []) do not work' do
          subject << fact_2_with_subject
          lambda { subject[0] } . should raise_exception NoMethodError
        end

        it '#<< returns self, so chaining is possible' do
          (subject << fact_2_with_subject).should == subject
        end
      end

      describe 'adding a fact with a ref to a context' do

        it 'fact_2_with_subject has a context_subject that refers to context and created_by' do
          subject << context_visibility
          subject << context_created_by
          subject << fact_2_with_subject
          context_subject = fact_1.context_subject
          subject.by_subject(context_subject).should == [context_visibility, context_created_by]
        end
      end

      describe 'newest_time_stamp' do
        it 'returns nil for empty collection' do
          subject.newest_time_stamp.should be_nil
        end

        it 'returns a time_stamp' do
          subject << fact_2_with_subject
          subject.newest_time_stamp.should be_a(fact_2_with_subject.time_stamp.class)
        end

        it 'returns the newest time_stamp' do
          subject << fact_2_with_subject
          subject << fact_3_with_subject
          subject.newest_time_stamp.should == fact_3_with_subject.time_stamp
        end
      end

      describe 'validate that only "newer" elements are added' do
        before(:each) do
          fact_2_with_subject.stub(:time_stamp).and_return(TimeStamp.new(time: Time.utc(2013,05,9,12,0,0)))
          fact_3_with_subject.stub(:time_stamp).and_return(TimeStamp.new(time: Time.utc(2013,05,9,12,0,1)))
        end

        it 'adding an element with a newer time_stamp succeeds' do
          subject << fact_2_with_subject
          subject << fact_3_with_subject
        end

        it 'adding an element with an older time_stamp fails' do
          fact_2_with_subject # will be older then fact_3_with_subject
          subject << fact_3_with_subject
          lambda { subject << fact_2_with_subject } . should raise_error OutOfOrderError
        end

        it 'adding an element with an equal time_stamp fails' do
          subject << fact_2_with_subject
          lambda { subject << fact_2_with_subject } . should raise_error OutOfOrderError
        end
      end

      describe 'oldest_time_stamp' do
        it 'returns nil for empty collection' do
          subject.oldest_time_stamp.should be_nil
        end

        it 'returns a time_stamp' do
          subject << fact_2_with_subject
          subject.oldest_time_stamp.should be_a(fact_2_with_subject.time_stamp.class)
        end

        it 'returns the oldest time_stamp' do
          subject << fact_2_with_subject
          subject << fact_3_with_subject
          subject.oldest_time_stamp.should == fact_2_with_subject.time_stamp
        end
      end

      describe 'context_facts must all come before first use by a fact' do
        it 'adding a context, depending fact, another context with same subject fail' do
          subject << context_visibility
          subject << fact_2_with_subject
          lambda{ subject << context_created_by }.should raise_error OutOfOrderError
        end

        # testing private functionality (kept temporarily as documentation)
        # A hash with all the context_subjects that are used by at least one fact.
        # Needed for the validation that no context may be added that is
        # referred from a fact that is already in the fact stream.
        describe 'used_context_subjects' do
          # testing an internal variable ...

          let(:used_context_subjects) do
            subject.instance_variable_get(:@used_context_subjects)
          end

          it 'is empty initially' do
            used_context_subjects.should be_empty
          end

          it 'adding a context alone does not create an entry' do
            subject << context_visibility
            used_context_subjects.should be_empty
          end

          it 'adding a context and a depending fact create an entry' do
            subject << context_visibility
            subject << fact_2_with_subject
            used_context_subjects[context_subject_1].should == true
          end
        end
      end

      describe 'validate that facts do not have errors when loading in the Fact::Collection' do
        it 'succeeds with a fact from factory' do
           subject << fact_2_with_subject # should_not raise_error
        end

        it 'raises FactError with message when fact.errors has errors' do
           context_visibility.stub(:errors).and_return(['Error 1', 'Error 2'])
           lambda { subject << context_visibility } . should raise_error(
             FactError,
             'Error 1, Error 2.')
        end
      end

      describe 'by_subject : ' do
        it 'finds entries for a given subject' do
          subject << context_visibility
          subject << context_created_by
          subject << context_original_source
          context_visibility.subject.should == context_subject_1 # assert test set-up
          context_created_by.subject.should == context_subject_1 # assert test set-up
          context_original_source.subject.should == context_subject_2 # assert test set-up
          subject.by_subject(context_subject_1).first.should == context_visibility
          subject.by_subject(context_subject_1).last.should == context_created_by
          subject.by_subject(context_subject_2).single.should == context_original_source
        end
      end

      describe 'TestFactories::Fact::Collection' do
        describe '.fact_2_3' do
          it 'has the given context_subject with explicit subject arg' do
            fact_2_3.each do |fact|
              fact.context_subject.should == context_subject_1
            end
          end
        end

        describe '.contexts' do
          it 'has a visibility' do
            contexts.select do |context|
              context.predicate == 'context:visibility'
            end.size.should == 1
          end

          it 'has a created_by' do
            contexts.select do |context|
              context.predicate == 'dcterms:creator'
            end.size.should == 1
          end

          it 'has an original_source' do
            contexts.select do |context|
              context.predicate == 'prov:source'
            end.size.should == 1
          end

          it 'has the given subjects with explicit subject arg' do
            contexts.each do |context|
              context.subject.should == context_subject_1
            end
          end
        end
      end
    end
  end
end
