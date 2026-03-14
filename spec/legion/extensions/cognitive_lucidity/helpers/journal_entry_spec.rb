# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLucidity::Helpers::JournalEntry do
  let(:dream_state) do
    s = Legion::Extensions::CognitiveLucidity::Helpers::DreamState.new(
      theme:          :ocean,
      content:        'swimming in warm light',
      lucidity_level: 0.7,
      stability:      0.8
    )
    allow(s).to receive(:rand).and_return(0.5)
    s.reality_test!(:hand_check)
    s.end!
    s
  end

  subject(:entry) { described_class.new(dream_state: dream_state, insights: ['felt peaceful']) }

  describe '#initialize' do
    it 'assigns a unique id' do
      expect(entry.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'records the dream_state_id' do
      expect(entry.dream_state_id).to eq(dream_state.id)
    end

    it 'captures content_summary' do
      expect(entry.content_summary).to eq(dream_state.content)
    end

    it 'captures lucidity_achieved' do
      expect(entry.lucidity_achieved).to eq(dream_state.lucidity_level.round(10))
    end

    it 'captures reality_tests_performed' do
      expect(entry.reality_tests_performed).not_to be_empty
    end

    it 'captures themes as frozen array' do
      expect(entry.themes).to be_frozen
    end

    it 'captures insights' do
      expect(entry.insights).to include('felt peaceful')
    end

    it 'sets recorded_at timestamp' do
      expect(entry.recorded_at).to be_a(Time)
    end

    it 'is immutable (frozen)' do
      expect(entry).to be_frozen
    end

    it 'captures false_awakening_count' do
      expect(entry.false_awakening_count).to eq(dream_state.false_awakening_count)
    end

    it 'captures duration_seconds' do
      expect(entry.duration_seconds).to be >= 0
    end
  end

  describe '#lucidity_label' do
    it 'returns :lucid for high lucidity' do
      expect(entry.lucidity_label).to eq(:lucid)
    end

    it 'returns :non_lucid for zero lucidity' do
      s = Legion::Extensions::CognitiveLucidity::Helpers::DreamState.new(
        theme: :test, content: 'quiet', lucidity_level: 0.0
      )
      s.end!
      e = described_class.new(dream_state: s)
      expect(e.lucidity_label).to eq(:non_lucid)
    end

    it 'returns :fully_lucid for very high lucidity' do
      s = Legion::Extensions::CognitiveLucidity::Helpers::DreamState.new(
        theme: :test, content: 'x', lucidity_level: 0.95
      )
      s.end!
      e = described_class.new(dream_state: s)
      expect(e.lucidity_label).to eq(:fully_lucid)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = entry.to_h
      expect(h.keys).to include(
        :id, :dream_state_id, :content_summary, :lucidity_achieved,
        :lucidity_label, :reality_tests_performed, :themes, :insights,
        :false_awakening_count, :duration_seconds, :steered, :recorded_at
      )
    end

    it 'includes the lucidity_label' do
      expect(entry.to_h[:lucidity_label]).to eq(entry.lucidity_label)
    end
  end
end
