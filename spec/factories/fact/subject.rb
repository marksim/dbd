module Factories
  module Fact
    module Subject

      def self.factory_for
        ::Dbd::Fact::Subject
      end

      def self.fixed_subject
        factory_for.new(uuid: "2e9fbc87-2e94-47e9-a8fd-121cc4bc3e8f")
      end

      def self.fixed_provenance_subject
        factory_for.new(uuid: "40fab407-9b04-4a51-9a52-d978abfcbb1f")
      end
    end
  end
end
