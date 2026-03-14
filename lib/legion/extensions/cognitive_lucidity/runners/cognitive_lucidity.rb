# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLucidity
      module Runners
        module CognitiveLucidity
          extend self

          def begin_dream(theme:, content:, engine: nil, **)
            eng = engine || default_engine
            result = eng.begin_dream(theme: theme, content: content, **)
            Legion::Logging.debug "[cognitive_lucidity] begin_dream theme=#{theme} id=#{result[:dream_id]}"
            result.merge(success: true)
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def reality_test(dream_id:, test_type:, engine: nil, **)
            eng = engine || default_engine
            result = eng.reality_test(dream_id: dream_id, test_type: test_type)
            Legion::Logging.debug "[cognitive_lucidity] reality_test dream_id=#{dream_id} " \
                                  "test=#{test_type} outcome=#{result[:outcome]}"
            result
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def steer_dream(dream_id:, direction:, engine: nil, **)
            eng = engine || default_engine
            result = eng.steer_dream(dream_id: dream_id, direction: direction)
            Legion::Logging.debug "[cognitive_lucidity] steer_dream dream_id=#{dream_id} " \
                                  "direction=#{direction} success=#{result[:success]}"
            result
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def end_dream(dream_id:, insights: [], engine: nil, **)
            eng = engine || default_engine
            result = eng.end_dream(dream_id: dream_id, insights: insights)
            Legion::Logging.debug "[cognitive_lucidity] end_dream dream_id=#{dream_id} " \
                                  "lucidity=#{result[:lucidity_achieved]}"
            result
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def lucidity_status(engine: nil, **)
            eng = engine || default_engine
            active = eng.active_dream
            report = eng.lucidity_report
            Legion::Logging.debug "[cognitive_lucidity] lucidity_status active=#{!active.nil?}"
            {
              success:      true,
              active_dream: if active
                              {
                                id:             active.id,
                                theme:          active.theme,
                                lucidity_level: active.lucidity_level,
                                stability:      active.stability,
                                lucidity_label: active.lucidity_label
                              }
                            end,
              report:       report
            }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def journal_entries(limit: 20, engine: nil, **)
            eng     = engine || default_engine
            entries = eng.journal.last(limit).map(&:to_h)
            Legion::Logging.debug "[cognitive_lucidity] journal_entries count=#{entries.size}"
            { success: true, count: entries.size, entries: entries }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          private

          def default_engine
            @default_engine ||= Helpers::LucidityEngine.new
          end
        end
      end
    end
  end
end
