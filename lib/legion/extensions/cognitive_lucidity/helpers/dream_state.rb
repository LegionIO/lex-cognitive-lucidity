# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveLucidity
      module Helpers
        class DreamState
          attr_reader :id, :lucidity_level, :awareness, :content, :theme, :vividness, :stability, :emotional_tone, :started_at, :reality_tests_performed,
                      :false_awakening_count, :steered, :ended_at

          def initialize(theme:, content:, vividness: 0.5, stability: 0.7,
                         emotional_tone: :neutral, lucidity_level: 0.0, **)
            @id                      = SecureRandom.uuid
            @theme                   = theme
            @content                 = content
            @vividness               = vividness.clamp(0.0, 1.0)
            @stability               = stability.clamp(0.0, 1.0)
            @emotional_tone          = emotional_tone
            @lucidity_level          = lucidity_level.clamp(0.0, 1.0)
            @awareness               = @lucidity_level > 0.0
            @started_at              = Time.now.utc
            @reality_tests_performed = []
            @false_awakening_count   = 0
            @steered                 = false
            @active                  = true
          end

          def active?
            @active
          end

          def lucidity_label
            thresholds = [
              [0.0, :non_lucid],
              [0.2, :pre_lucid],
              [0.5, :semi_lucid],
              [0.75, :lucid],
              [0.9, :fully_lucid]
            ]
            label = :non_lucid
            thresholds.each do |threshold, lbl|
              label = lbl if @lucidity_level >= threshold
            end
            label
          end

          def reality_test!(test_type)
            raise ArgumentError, "unknown test type: #{test_type}" unless Constants::REALITY_TEST_TYPES.include?(test_type)

            result = perform_reality_test(test_type)
            @reality_tests_performed << {
              test_type:      test_type,
              result:         result[:outcome],
              lucidity_delta: result[:lucidity_delta],
              tested_at:      Time.now.utc
            }

            if result[:false_awakening]
              @false_awakening_count += 1
              return { outcome: :false_awakening, lucidity_delta: 0.0, false_awakening: true }
            end

            @lucidity_level = (@lucidity_level + result[:lucidity_delta]).clamp(0.0, 1.0)
            @awareness = @lucidity_level > 0.0

            { outcome: result[:outcome], lucidity_delta: result[:lucidity_delta], false_awakening: false }
          end

          def steer!(direction)
            return { success: false, reason: :insufficient_lucidity } if @lucidity_level < 0.5

            @content   = "#{@content} [steered: #{direction}]"
            @steered   = true
            @stability = (@stability - 0.1).clamp(0.0, 1.0)

            { success: true, direction: direction, new_stability: @stability }
          end

          def destabilize!(amount)
            @stability = (@stability - amount.clamp(0.0, 1.0)).clamp(0.0, 1.0)
            @lucidity_level = (@lucidity_level - Constants::LUCIDITY_DECAY).clamp(0.0, 1.0)
            @awareness = @lucidity_level > 0.0
            { stability: @stability, lucidity_level: @lucidity_level }
          end

          def stabilize!(amount)
            @stability = (@stability + amount.clamp(0.0, 1.0)).clamp(0.0, 1.0)
            { stability: @stability, lucidity_level: @lucidity_level }
          end

          def end!
            @active = false
            @ended_at = Time.now.utc
          end

          def duration_seconds
            end_time = @ended_at || Time.now.utc
            (end_time - @started_at).round(10)
          end

          private

          def perform_reality_test(test_type)
            false_awakening = rand < Constants::FALSE_AWAKENING_CHANCE

            return { outcome: :failed, lucidity_delta: 0.0, false_awakening: true } if false_awakening

            base_gain = test_base_gain(test_type)
            stability_modifier = @stability < 0.3 ? 0.5 : 1.0
            lucidity_delta = (base_gain * stability_modifier).round(10)

            { outcome: :passed, lucidity_delta: lucidity_delta, false_awakening: false }
          end

          def test_base_gain(test_type)
            gains = {
              text_stability: 0.15,
              hand_check:     0.20,
              time_check:     0.10,
              memory_check:   0.12,
              logic_check:    0.18
            }
            gains.fetch(test_type, 0.10)
          end
        end
      end
    end
  end
end
