# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLucidity
      module Helpers
        class LucidityEngine
          attr_reader :journal

          def initialize
            @dreams  = {}
            @journal = []
          end

          def begin_dream(theme:, content:, vividness: 0.5, stability: 0.7,
                          emotional_tone: :neutral, lucidity_level: 0.0, **)
            evict_oldest_dream! if @dreams.size >= Constants::MAX_DREAMS

            state = DreamState.new(
              theme:          theme,
              content:        content,
              vividness:      vividness,
              stability:      stability,
              emotional_tone: emotional_tone,
              lucidity_level: lucidity_level
            )
            @dreams[state.id] = state
            {
              dream_id:      state.id,
              theme:         state.theme,
              lucidity_level: state.lucidity_level,
              stability:     state.stability
            }
          end

          def reality_test(dream_id:, test_type:, **)
            state = @dreams[dream_id]
            return { success: false, error: 'dream not found' } unless state
            return { success: false, error: 'dream is not active' } unless state.active?

            result = state.reality_test!(test_type.to_sym)
            {
              success:        true,
              dream_id:       dream_id,
              outcome:        result[:outcome],
              lucidity_delta: result[:lucidity_delta],
              lucidity_level: state.lucidity_level,
              false_awakening: result[:false_awakening]
            }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def steer_dream(dream_id:, direction:, **)
            state = @dreams[dream_id]
            return { success: false, error: 'dream not found' } unless state
            return { success: false, error: 'dream is not active' } unless state.active?

            result = state.steer!(direction)
            result.merge(dream_id: dream_id)
          end

          def end_dream(dream_id:, insights: [], **)
            state = @dreams[dream_id]
            return { success: false, error: 'dream not found' } unless state
            return { success: false, error: 'dream is not active' } unless state.active?

            state.end!
            entry = JournalEntry.new(dream_state: state, insights: insights)
            add_journal_entry(entry)

            {
              success:          true,
              dream_id:         dream_id,
              journal_entry_id: entry.id,
              lucidity_achieved: entry.lucidity_achieved,
              duration_seconds: entry.duration_seconds
            }
          end

          def all_dreams
            @dreams.values
          end

          def active_dream
            @dreams.values.find(&:active?)
          end

          def lucidity_report
            entries = @journal
            return base_report if entries.empty?

            total         = entries.size
            avg_lucidity  = entries.sum { |e| e.lucidity_achieved } / total.to_f
            false_awakenings = entries.sum { |e| e.false_awakening_count }
            steered_count = entries.count { |e| e.steered }

            test_totals   = Hash.new(0)
            test_passes   = Hash.new(0)
            entries.each do |entry|
              entry.reality_tests_performed.each do |rt|
                test_totals[rt[:test_type]] += 1
                test_passes[rt[:test_type]] += 1 if rt[:result] == :passed
              end
            end

            success_rates = test_totals.transform_values do |count|
              test_type = test_totals.key(count)
              count.positive? ? (test_passes[test_type].to_f / count).round(10) : 0.0
            end

            {
              total_dreams:          total,
              avg_lucidity:          avg_lucidity.round(10),
              false_awakening_count: false_awakenings,
              steered_count:         steered_count,
              test_success_rates:    success_rates
            }
          end

          def most_lucid_dreams(limit: 5, **)
            @journal
              .sort_by { |e| -e.lucidity_achieved }
              .first(limit)
              .map(&:to_h)
          end

          def theme_analysis
            theme_map = Hash.new(0)
            lucidity_by_theme = Hash.new { |h, k| h[k] = [] }

            @journal.each do |entry|
              Array(entry.themes).each do |theme|
                theme_map[theme] += 1
                lucidity_by_theme[theme] << entry.lucidity_achieved
              end
            end

            theme_map.map do |theme, count|
              values = lucidity_by_theme[theme]
              avg    = values.empty? ? 0.0 : (values.sum / values.size.to_f).round(10)
              { theme: theme, occurrences: count, avg_lucidity: avg }
            end.sort_by { |t| -t[:occurrences] }
          end

          private

          def add_journal_entry(entry)
            @journal.shift while @journal.size >= Constants::MAX_JOURNAL_ENTRIES
            @journal << entry
          end

          def evict_oldest_dream!
            oldest_id = @dreams.min_by { |_id, state| state.started_at }&.first
            @dreams.delete(oldest_id) if oldest_id
          end

          def base_report
            {
              total_dreams:          0,
              avg_lucidity:          0.0,
              false_awakening_count: 0,
              steered_count:         0,
              test_success_rates:    {}
            }
          end
        end
      end
    end
  end
end
