require 'spec_helper'

module Dbd
  module Graph
    describe Base do

      let(:provenance_fact_1) { Factories::ProvenanceFact.context }
      let(:provenance_fact_collection_1) { Factories::Fact::Collection.provenance_facts }
      let(:fact_collection_1_2) { Factories::Fact::Collection.fact_1_2(provenance_fact_1.subject) }

      describe "create a graph" do
        it "does not fail" do
          described_class.new # should_not raise_error
        end
      end

      describe "#to_CSV with provenance_facts" do
        before do
          provenance_fact_collection_1.each do |provenance_fact|
            subject.fact_collection << provenance_fact
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
            subject.to_CSV.lines.size.should == 4
          end

          it "ends with a newline" do
            subject.to_CSV.lines.last[-1].should == "\n"
          end
        end

        describe "has all properties of the provenance_fact_collection" do

          let(:first_line) do
            subject.to_CSV.lines.to_a.first.chomp
          end

          it "has id (a uuid) as first value" do
            first_line.split(',')[0].should match(/"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"/)
          end

          it "has time_stamp as second value" do
            first_line.split(',')[1].should match(/"\d{4}-\d\d-\d\d \d\d:\d\d:\d\d UTC"/)
          end

          it "has an empty third value" do
            first_line.split(',')[2].should == "\"\""
          end

          it "has subject_id as 4th value" do
            first_line.split(',')[3].should match(/"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"/)
          end

          it "has data_property as 5th value" do
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

      describe "#to_CSV with facts" do
        before do
          fact_collection_1_2.each do |fact|
            subject.fact_collection << fact
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
            subject.to_CSV.lines.size.should == 2
          end

          it "ends with a newline" do
            subject.to_CSV.lines.last[-1].should == "\n"
          end
        end

        describe "has all properties of the fact_collection" do

          let(:first_line) do
            subject.to_CSV.lines.to_a.first.chomp
          end

          it "has id (a uuid) as first value" do
            first_line.split(',')[0].should match(/"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"/)
          end

          it "has time_stamp as second value" do
            first_line.split(',')[1].should match(/"\d{4}-\d\d-\d\d \d\d:\d\d:\d\d UTC"/)
          end

          it "has provenance_fact_1.subject as third value" do
            first_line.split(',')[2].should == "\"#{provenance_fact_1.subject.to_s}\""
          end

          it "has subject_id as 4th value" do
            first_line.split(',')[3].should match(/"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"/)
          end

          it "has data_property as 5th value" do
            first_line.split(',')[4].should == '"http://example.org/test/name"'
          end

          it "has object as 6th value" do
            first_line.split(',')[5].should == '"Gandhi"'
          end
        end
      end

      describe "#to_CSV with provenance_facts and facts" do

        before do
          provenance_fact_collection_1.each do |provenance_fact|
            subject.fact_collection << provenance_fact
          end
          fact_collection_1_2.each do |fact|
            subject.fact_collection << fact
           end
        end

        it "has six lines" do
          subject.to_CSV.lines.size.should == 6
        end

        describe "handles comma, double quote and newline correctly" do
          it "has original_source with special characters and double quote escaped" do
            subject.to_CSV.should match(/"this has a comma , a newline \n and a double quote """/)
          end
        end
      end
    end
  end
end
