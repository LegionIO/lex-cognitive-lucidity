# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveLucidity
      module Helpers
        class JournalEntry
          attr_reader :id, :dream_state_id, :content_summary, :lucidity_achieved,
                      :reality_tests_performed, :themes, :insights, :recorded_at,
                      :false_awakening_count, :duration_seconds, :steered

          def initialize(dream_state:, insights: [], **)
            @id                    = SecureRandom.uuid
            @dream_state_id        = dream_state.id
            @content_summary       = dream_state.content.to_s
            @lucidity_achieved     = dream_state.lucidity_level.round(10)
            @reality_tests_performed = dream_state.reality_tests_performed.dup.freeze
            @themes                = Array(dream_state.theme).freeze
            @insights              = Array(insights).freeze
            @recorded_at           = Time.now.utc
            @false_awakening_count = dream_state.false_awakening_count
            @duration_seconds      = dream_state.duration_seconds
            @steered               = dream_state.steered
            freeze
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
              label = lbl if @lucidity_achieved >= threshold
            end
            label
          end

          def to_h
            {
              id:                      @id,
              dream_state_id:          @dream_state_id,
              content_summary:         @content_summary,
              lucidity_achieved:       @lucidity_achieved,
              lucidity_label:          lucidity_label,
              reality_tests_performed: @reality_tests_performed,
              themes:                  @themes,
              insights:                @insights,
              false_awakening_count:   @false_awakening_count,
              duration_seconds:        @duration_seconds,
              steered:                 @steered,
              recorded_at:             @recorded_at
            }
          end
        end
      end
    end
  end
end
