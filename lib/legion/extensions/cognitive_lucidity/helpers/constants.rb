# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLucidity
      module Helpers
        module Constants
          MAX_JOURNAL_ENTRIES = 500
          MAX_DREAMS          = 100

          LUCIDITY_LEVELS = %i[non_lucid pre_lucid semi_lucid lucid fully_lucid].freeze

          REALITY_TEST_TYPES = %i[
            text_stability
            hand_check
            time_check
            memory_check
            logic_check
          ].freeze

          LUCIDITY_DECAY = 0.05
          FALSE_AWAKENING_CHANCE = 0.1

          DREAM_QUALITY_LABELS = {
            0.0..0.2 => :poor,
            0.2..0.4 => :fragmented,
            0.4..0.6 => :ordinary,
            0.6..0.8 => :vivid,
            0.8..1.0 => :hyper_vivid
          }.freeze

          module_function

          def label_for(value)
            DREAM_QUALITY_LABELS.each do |range, label|
              return label if range.cover?(value.clamp(0.0, 1.0))
            end
            :ordinary
          end
        end
      end
    end
  end
end
