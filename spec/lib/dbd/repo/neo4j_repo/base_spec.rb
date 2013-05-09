require 'spec_helper'

module Dbd
  module Repo
    module Neo4jRepo
      describe Base do
        it "has the Neography class" do
          ::Neography
        end

        it "can insert a node", :neo4j => true do
          subject.create_node("age" => 31, "name" => "Max")
        end

        it "can create a relationship", :neo4j => true do
          max = subject.create_node("age" => 31, "name" => "Max")
          roel = subject.create_node("age" => 33, "name" => "Roel")
          subject.create_relationship("co-founders", max, roel)
        end

        describe "play with a minimal graph", :neo4j => true do

          let(:max) {subject.create_node("age" => 31, "name" => "Max")}

          let(:roel) {roel = subject.create_node("age" => 33, "name" => "Roel")}

          before(:each) do
            subject.create_relationship("co-founders", max, roel)
          end

          it "can get the root node" do
            root = subject.get_root
          end

          it "can create a node index" do
            subject.create_node_index("name_index_2", "exact", "lucene")
            subject.list_node_indexes.keys.should include("name_index_2")
          end

          it "can list the indexes" do
            subject.list_node_indexes
          end

          it "can add a node to an index" do
            subject.add_node_to_index("name_index", "name", "Max", max)
            subject.list_node_indexes.keys.should include("name_index")
          end

          it "can find entries in the index" do
            subject.add_node_to_index("name_index", "name", "Max", max)
            result = subject.get_node_index("name_index", "name", "Max")
            result.size.should > 0
          end

          describe "query nodes", :neo4j_performance => true do

            it "can get all nodes with a query" do
              result = subject.execute_query("start n=node(*) return n")
              result["data"].last.single["data"]["name"].should == "Roel"
            end

            it "can get the last 5 nodes with load_node" do
              result = subject.execute_query("start n=node(*) return n")
              node_uris = result["data"].last(5).map{|n| n.single["self"]}
              nodes = node_uris.map do |uri|
                subject.load_node(uri)
              end
              nodes.last.should be_a(Neography::Node)
            end

            let(:node) do
              result = subject.execute_query("start n=node(*) return n")
              uri = result["data"].last.single["self"]
              subject.load_node(uri)
            end

            it "has age 33" do
              node.age.should == 33
            end
          end
        end
      end
    end
  end
end
