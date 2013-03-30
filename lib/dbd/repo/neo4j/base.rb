module Dbd
  module Repo
    module Neo4j
      class Base

        def initialize
          @neo = Neography::Rest.new
        end

        def create_node(hash)
          @neo.create_node(hash)
        end

        def create_relationship(p, s, o)
          @neo.create_relationship(p, s, o)
        end

        def list_node_indexes
          @neo.list_node_indexes
        end

        def add_node_to_index(index, key, value, node)
          @neo.add_node_to_index(index, key, value, node)
        end

        def execute_query(query_string)
          @neo.execute_query(query_string)
        end

        def get_root
          @neo.get_root
        end

        def load_node(uri)
          Neography::Node.load(uri)
        end

      end
    end
  end
end
