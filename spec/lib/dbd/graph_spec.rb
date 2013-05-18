require 'spec_helper'

module Dbd
  describe Graph do

    def new_subject
      Fact.new_subject
    end

    let(:data_fact) { Factories::Fact.data_fact(new_subject, new_subject) }
    let(:fact_no_subject) { Factories::Fact.data_fact(new_subject, nil) }
    let(:fact_no_provenance) { Factories::Fact.data_fact(nil, new_subject) }

    let(:provenance_facts) { Factories::Fact::Collection.provenance_facts(new_subject) }
    let(:provenance_fact_1) { provenance_facts.first }
    let(:fact_2_3) { Factories::Fact::Collection.fact_2_3(provenance_fact_1.subject) }

    let(:subject_regexp) { Fact::Subject.regexp }
    let(:id_regexp) { Fact::ID.regexp }

    describe "create a graph" do
      it "does not fail" do
        described_class.new # should_not raise_error
      end
    end

    describe "<< " do
      describe "a Fact" do
        it "a data_fact does not fail" do
          subject << data_fact
        end

        it "a provenance_fact does not fail" do
          subject << provenance_fact_1
        end

        it "two facts does not fail" do
          subject << provenance_fact_1
          subject << data_fact
        end

        it "fact with missing subject raises FactError" do
          lambda { subject << fact_no_subject } . should raise_error FactError
        end

        it "fact with missing provenance raises FactError" do
          lambda { subject << fact_no_provenance } . should raise_error FactError
        end
      end

      describe "sets the time_stamp and adds 2 nanoseconds if needed" do

        # NOTE: reduced the far_future from 2500 to 2250 as work around for
        #       http://jira.codehaus.org/browse/JRUBY-7095
        let(:far_future) { TimeStamp.new(time: Time.new(2250,1,1,12,0,0).utc) }

        it "don't touch the time_stamp if already set" do
          data_fact.time_stamp = far_future
          subject << data_fact
          subject.first.time_stamp.should == far_future
        end

        describe "sets the time_stamp if not yet set" do

          let(:fake_time_stamp) { TimeStamp.new }
          let(:shifted_fake_time_stamp) { fake_time_stamp + Rational('2/1_000_000_000')}

          before(:each) do
            # get this before setting the stub
            far_future # get this before setting the stub
            fake_time_stamp # get this before setting the stub
            shifted_fake_time_stamp # get this before setting the stub
          end

          it "sets it (to TimeStamp.new)" do
            TimeStamp.stub(:new).and_return(fake_time_stamp)
            data_fact.time_stamp.should be_nil # assert pre-condition
            subject << data_fact
            subject.first.time_stamp.should == fake_time_stamp
          end

          it "raise OutOfOrderError if new_time_stamp is smaller than newest_time_stamp" do
            subject.stub(:newest_time_stamp).and_return(far_future)
            # this "should_receive" is needed to test that the exception is called in
            # enforce_strictly_monotonic_time (and not later in Fact::Collection)
            data_fact.should_receive(:time_stamp=).exactly(0).times
            lambda { subject << data_fact } . should raise_error OutOfOrderError
          end

          it "sets a slightly higher time_stamp if new_time_stamp equal to newest_time_stamp" do
            subject.stub(:newest_time_stamp).and_return(fake_time_stamp)
            TimeStamp.stub(:new).and_return(fake_time_stamp)
            TimeStamp.any_instance.should_receive(:+).with(Rational('2/1_000_000_000')).
              and_return(shifted_fake_time_stamp)
            subject << data_fact
            subject.first.time_stamp.should == shifted_fake_time_stamp
          end
        end
      end
    end

    describe "#to_CSV with only provenance_facts" do
      before do
        provenance_facts.each_with_index do |provenance_fact, index|
          subject << provenance_fact
        end
      end

      it "returns a string" do
        subject.to_CSV.should be_a(String)
      end

      it "returns a string in UTF-8 encoding" do
        subject.to_CSV.encoding.should == Encoding::UTF_8
      end

      it "returns a string with comma's" do
        subject.to_CSV.should match(/\A"[^",]+","[^",]+","[^",]*","[^",]+"/)
      end

      describe "with a single provenance_fact collection" do
        it "has three logical lines (but one with embedded newline)" do
          subject.to_CSV.lines.count.should == 4
        end

        it "ends with a newline" do
          subject.to_CSV.lines.to_a.last[-1].should == "\n"
        end
      end

      describe "has all attributes of the provenance_fact_collection" do

        let(:first_line) do
          subject.to_CSV.lines.to_a.first.chomp
        end

        it "has id (a Fact::ID) as first value" do
          first_line.split(',')[0].gsub(/"/, '').should match(id_regexp)
        end

        it "has time_stamp as second value" do
          first_line.split(',')[1].should match(TimeStamp.to_s_regexp)
        end

        it "has an empty third value (signature of a provenance_fact)" do
          first_line.split(',')[2].should == "\"\""
        end

        it "has subject as 4th value" do
          first_line.split(',')[3].gsub(/"/, '').should match(subject_regexp)
        end

        it "has data_predicate as 5th value" do
          first_line.split(',')[4].should == '"https://data.vandenabeele.com/ontologies/provenance#context"'
        end

        it "has object as 6th value" do
          first_line.split(',')[5].should == '"public"'
        end
      end

      describe "handles comma, double quote and newline correctly" do
        it "has original_source with special characters and double quote escaped" do
          subject.to_CSV.should match(/"this has a comma , a newline \n and a double quote """/)
        end
      end
    end

    describe "#to_CSV with only facts" do
      before do
        fact_2_3.each_with_index do |fact, index|
          subject << fact
         end
      end

      it "returns a string" do
        subject.to_CSV.should be_a(String)
      end

      it "returns a string in UTF-8 encoding" do
        subject.to_CSV.encoding.should == Encoding::UTF_8
      end

      it "returns a string with comma's" do
        subject.to_CSV.should match(/\A"[^",]+","[^",]+","[^",]+"/)
      end

      describe "with a single fact collection" do
        it "has two lines" do
          subject.to_CSV.lines.count.should == 2
        end

        it "ends with a newline" do
          subject.to_CSV.lines.to_a.last[-1].should == "\n"
        end
      end

      describe "has all attributes of the fact_collection" do

        let(:first_line) do
          subject.to_CSV.lines.to_a.first.chomp
        end

        it "has id (a Fact::ID) as first value" do
          first_line.split(',')[0].gsub(/"/, '').should match(id_regexp)
        end

        it "has time_stamp as second value" do
          first_line.split(',')[1].should match(TimeStamp.to_s_regexp)
        end

        it "has provenance_fact_1.subject as third value" do
          first_line.split(',')[2].should == "\"#{provenance_fact_1.subject.to_s}\""
        end

        it "has subject as 4th value" do
          first_line.split(',')[3].gsub(/"/, '').should match(subject_regexp)
        end

        it "has data_predicate as 5th value" do
          first_line.split(',')[4].should == '"http://example.org/test/name"'
        end

        it "has object as 6th value" do
          first_line.split(',')[5].should == '"Mandela"'
        end
      end
    end

    describe "#to_CSV with provenance_facts and facts" do

      before do
        provenance_facts.each do |provenance_fact|
          subject << provenance_fact
        end
        fact_2_3.each do |fact|
          subject << fact
         end
      end

      it "has six lines" do
        subject.to_CSV.lines.count.should == 6
      end
    end
  end
end
