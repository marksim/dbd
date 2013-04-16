require 'spec_helper'

module Dbd
  module Graph
    describe Graph do
      describe "create a graph" do
        it "does not fail" do
          described_class.new # should_not raise_error
        end
      end

      describe "has an 'collections' array" do
        it "empty for new object" do
          subject.collections.should == []
        end

        it "adding 1 entry works" do
          subject << :a
          subject.collections.size.should == 1
        end

        it "adding 2 entries works" do
          subject << :a
          subject.collections.size.should == 1
          subject << :b
          subject.collections.size.should == 2
          subject.collections.first.should == :a
          subject.collections[1].should == :b
        end

        it "the returned array is frozen" do
          subject.collections.should be_frozen
        end
      end

      describe "to_CSV" do
        it "returns a string" do
          subject.to_CSV.should be_a(String)
        end

        it "returns a string in UTF-8 encoding" do
          subject.to_CSV.encoding.should == Encoding::UTF_8
        end

        it "returns a string with comma's" do
          subject.to_CSV.should match(/\A"[^",]+","[^",]+","[^",]+"/)
        end

      end
    end
  end
end
