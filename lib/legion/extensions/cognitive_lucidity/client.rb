# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLucidity
      class Client
        include Runners::CognitiveLucidity

        attr_reader :engine

        def initialize(engine: nil, **)
          @default_engine = engine || Helpers::LucidityEngine.new
        end

        private

        attr_reader :default_engine
      end
    end
  end
end
