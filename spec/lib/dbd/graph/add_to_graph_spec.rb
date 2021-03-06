require 'spec_helper'

module Dbd
  describe Graph do

    def new_subject
      Fact.factory.new_subject
    end

    let(:data_fact) { TestFactories::Fact.data_fact(new_subject, new_subject) }
    let(:fact_no_subject) { TestFactories::Fact.data_fact(new_subject, nil) }
    let(:fact_no_context) { TestFactories::Fact.data_fact(nil, new_subject) }

    let(:context_facts) { TestFactories::Fact::Collection.context_facts(new_subject) }
    let(:context_fact_1) { context_facts.first }

    let(:subject_regexp) { Fact::Subject.regexp }

    let(:context) { TestFactories::Context.context }
    let(:resource) { TestFactories::Resource.facts_resource(context.subject) }
    let(:resource_array) { [context, resource]}

    describe 'create a graph' do
      it 'does not fail' do
        described_class.new # should_not raise_error
      end
    end

    describe '<< ' do
      describe 'a Fact' do
        it 'a data_fact does not fail' do
          subject << data_fact
        end

        it 'a context_fact does not fail' do
          subject << context_fact_1
        end

        it 'two facts does not fail' do
          subject << context_fact_1
          subject << data_fact
        end

        it 'fact with missing subject raises FactError' do
          lambda { subject << fact_no_subject } . should raise_error FactError
        end

        it 'fact with missing context raises FactError' do
          lambda { subject << fact_no_context } . should raise_error FactError
        end
      end

      describe 'sets the time_stamp and adds a random time (1..999 nanoseconds) if needed' do

        # NOTE: reduced the far_future from 2500 to 2250 as work around for
        #       http://jira.codehaus.org/browse/JRUBY-7095
        let(:far_future) { TimeStamp.new(time: Time.utc(2250,1,1,12,0,0)) }

        it "don't touch the time_stamp if already set" do
          data_fact.time_stamp = far_future
          subject << data_fact
          subject.first.time_stamp.should == far_future
        end

        describe 'sets the time_stamp if not yet set' do

          let(:near_future) { Time.now.utc + 100}
          let(:fake_time_stamp) { TimeStamp.new(time: near_future) }

          before(:each) do
            # get this before setting the stub
            fake_time_stamp # get this before setting the stub
          end

          it 'sets it (to TimeStamp.new)' do
            TimeStamp.stub(:new).and_return(fake_time_stamp)
            data_fact.time_stamp.should be_nil # assert pre-condition
            subject << data_fact
            subject.first.time_stamp.should == fake_time_stamp
          end

          it 'sends a slightly higher time_stamp than newest_time_stamp if Time.now <= newest_time_stamp' do
            subject.stub(:newest_time_stamp).and_return(fake_time_stamp)
            subject << data_fact
            subject.first.time_stamp.should > fake_time_stamp
            (subject.first.time_stamp - fake_time_stamp).should < Rational('1/1000_000') # 1 us
          end
        end
      end

      describe 'a Context and a Resource' do

        it 'does not fail' do
          subject << context
        end

        it 'Adds the facts from the context to the graph' do
          subject << context
          subject.size.should == 2
        end

        it 'Adds the facts from the context and the resource to the graph' do
          subject << context
          subject << resource
          subject.size.should == 4
          subject.first.should be_a(ContextFact)
          subject.last.class.should == Fact
        end
      end

      describe 'an array of Resources' do
        it 'does not fail' do
          subject << resource_array
        end

        it 'Adds the facts from the context and the resource to the graph' do
          subject << resource_array
          subject.first.class.should == ContextFact
          subject.last.class.should == Fact
          subject.size.should == 4
        end

        it 'goes 3 levels over collection deep' do
          subject << [resource_array]
          subject.size.should == 4
        end

        it 'works with different levels deep in 1 collection' do
          subject << [context, [[resource]]]
          subject.size.should == 4
        end
      end

      it 'returns self' do
        (subject << TestFactories::Fact::Collection.context_facts(new_subject)).should be_a(described_class)
      end
    end
  end
end
