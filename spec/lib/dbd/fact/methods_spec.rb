require 'spec_helper'

module Dbd
  describe Fact do

    let(:provenance_subject) { ProvenanceFact.new_subject }
    let(:subject) { described_class.new_subject }
    let(:fact_1) { Factories::Fact.fact_1(provenance_subject) }
    let(:fact_2_with_subject) { Factories::Fact.fact_2_with_subject(provenance_subject) }
    let(:fact_with_newline) { Factories::Fact.fact_with_newline(provenance_subject) }

    describe "time_stamp=" do
      it "checks the type (too easy to try to give a Time arg)" do
        lambda{ fact_1.time_stamp = Time.now }.should raise_error(ArgumentError)
      end

      describe "set_once" do

        let(:time_stamp_now) { TimeStamp.new }

        it "can be set when nil" do
          fact_1.time_stamp = time_stamp_now
          fact_1.time_stamp.should == time_stamp_now
        end

        describe "setting it two times" do
          it "with the value succeeds" do
            fact_1.time_stamp = time_stamp_now
            fact_1.time_stamp = time_stamp_now
          end

          it "with a different value raises a SetOnceError" do
            fact_1.time_stamp = time_stamp_now
            lambda{ fact_1.time_stamp = (time_stamp_now+1) }.should raise_error(RubyPeterV::SetOnceError)
          end
        end
      end
    end

    describe "short" do
      it "for a base fact shows provenance, subject, predicate, object" do
        fact_1.subject = subject
        fact_1.time_stamp = TimeStamp.new
        fact_1.short.should match(/^[0-9a-f]{8} : [0-9a-f]{8} : http:\/\/example\.org\/test\/ : Gandhi$/)
      end

      it "for a fact with a newline replaces it with a underscore" do
        fact_with_newline.subject = subject
        fact_with_newline.short.should match(/^[0-9a-f]{8} : [0-9a-f]{8} : http:\/\/example\.org\/test\/ : A long story_really.$/)
      end
    end

    describe "errors" do
      it "the factory has no errors" do
        fact_2_with_subject.errors.should be_empty
      end

      describe "without provenance_subject" do

        before(:each) do
          fact_2_with_subject.stub(:provenance_subject).and_return(nil)
        end

        it "errors returns an array with 1 error message" do
          fact_2_with_subject.errors.single.should match(/Provenance subject is missing/)
        end
      end

      describe "without subject" do

        before(:each) do
          fact_2_with_subject.stub(:subject).and_return(nil)
        end

        it "errors returns an array with an errorm message" do
          fact_2_with_subject.errors.single.should match(/Subject is missing/)
        end
      end
    end

    describe "attributes and values" do
      it "there are 6 attributes" do
        described_class.attributes.size.should == 6
      end

      it "first attribute is :id" do
        described_class.attributes.first.should == :id
      end

      it "there are 6 values" do
        fact_1.values.size.should == 6
      end
    end

    def values
      ["825e44d5-af33-4858-8047-549bd813daa8",
       "2013-06-17 21:55:09.967653012 UTC",
       "40fab407-9b04-4a51-9a52-d978abfcbb1f",
       "2e9fbc87-2e94-47e9-a8fd-121cc4bc3e8f",
       "http://example.org/test/name",
       "Gandhi"]
    end

    describe "from_values" do
      it "reads the values correctly" do
        fact = described_class.from_values(values)
        fact.values.should == values
      end
    end

    describe "provenance_fact?" do
      it "is false for a base fact or derived from it that is not a ProvenanceFact " do
        fact_1.provenance_fact?.should be_false
      end
    end
  end
end
