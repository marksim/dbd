require 'spec_helper'

module Dbd
  module Graph
    describe Collection do

      let(:fact_origin_collection_1) { Factories::FactOrigin::Collection.me_tijd }
      let(:fact_1) { Factories::Fact.fact_1 }
      let(:fact_collection_1_2) { Factories::Fact::Collection.fact_1_2 }
      let(:fact_collection_3_4) { Factories::Fact::Collection.fact_3_4 }

      describe "create a graph_collection" do
        it "new does not fail" do
          subject.should_not be_nil
        end

        it "adding a fact_origin_collection works" do
          subject << fact_origin_collection_1
          subject.count.should == 1
        end

        it "adding 2 fact_origin_collections fails" do
          subject << fact_origin_collection_1
          lambda { subject << fact_origin_collection_1 } . should raise_error(Collection::InternalError)
        end

        it "adding a fact_collection works" do
          subject << fact_collection_1_2
          subject.count.should == 1
        end

        it "adding 2 fact_collections works" do
          subject << fact_collection_1_2
          lambda { subject << fact_collection_3_4 } . should raise_error(Collection::InternalError)
        end
      end

      describe "newest_time_stamp" do
        it "returns nil for empty collection" do
          subject.newest_time_stamp.should be_nil
        end

        it "filters out fact_origin_collections from the collection" do
          subject << fact_origin_collection_1
          subject.newest_time_stamp.should be_nil
        end

        it "returns a time_stamp" do
          subject << fact_collection_1_2
          subject.newest_time_stamp.should be_a(fact_1.time_stamp.class)
        end

        it "returns the newest time_stamp" do
          subject << fact_collection_1_2
          subject.newest_time_stamp.should == fact_collection_1_2.last.time_stamp
        end
      end

      describe "oldest_time_stamp" do
        it "returns nil for empty collection" do
          subject.oldest_time_stamp.should be_nil
        end

        it "filters out fact_origin_collections from the collection" do
          subject << fact_origin_collection_1
          subject.oldest_time_stamp.should be_nil
        end

        it "returns a time_stamp" do
          subject << fact_collection_1_2
          subject.oldest_time_stamp.should be_a(fact_1.time_stamp.class)
        end

        it "returns the oldest time_stamp" do
          subject << fact_collection_1_2
          subject.oldest_time_stamp.should == fact_collection_1_2.first.time_stamp
        end
      end
    end
  end
end
