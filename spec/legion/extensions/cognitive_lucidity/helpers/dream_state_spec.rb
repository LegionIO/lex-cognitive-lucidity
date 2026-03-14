# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLucidity::Helpers::DreamState do
  subject(:state) do
    described_class.new(theme: :flying, content: 'soaring above clouds', vividness: 0.8, stability: 0.7)
  end

  describe '#initialize' do
    it 'assigns an id' do
      expect(state.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets theme' do
      expect(state.theme).to eq(:flying)
    end

    it 'sets content' do
      expect(state.content).to eq('soaring above clouds')
    end

    it 'clamps vividness to 0.0..1.0' do
      s = described_class.new(theme: :test, content: 'x', vividness: 1.5)
      expect(s.vividness).to eq(1.0)
    end

    it 'clamps stability to 0.0..1.0' do
      s = described_class.new(theme: :test, content: 'x', stability: -0.3)
      expect(s.stability).to eq(0.0)
    end

    it 'defaults lucidity_level to 0.0' do
      expect(state.lucidity_level).to eq(0.0)
    end

    it 'defaults awareness to false when lucidity is 0' do
      expect(state.awareness).to be false
    end

    it 'sets awareness to true when lucidity_level > 0' do
      s = described_class.new(theme: :test, content: 'x', lucidity_level: 0.5)
      expect(s.awareness).to be true
    end

    it 'starts active' do
      expect(state.active?).to be true
    end

    it 'sets started_at' do
      expect(state.started_at).to be_a(Time)
    end

    it 'initializes reality_tests_performed as empty array' do
      expect(state.reality_tests_performed).to be_empty
    end

    it 'initializes false_awakening_count to 0' do
      expect(state.false_awakening_count).to eq(0)
    end
  end

  describe '#lucidity_label' do
    it 'returns :non_lucid at 0.0' do
      expect(state.lucidity_label).to eq(:non_lucid)
    end

    it 'returns :pre_lucid at 0.2' do
      s = described_class.new(theme: :test, content: 'x', lucidity_level: 0.2)
      expect(s.lucidity_label).to eq(:pre_lucid)
    end

    it 'returns :semi_lucid at 0.5' do
      s = described_class.new(theme: :test, content: 'x', lucidity_level: 0.5)
      expect(s.lucidity_label).to eq(:semi_lucid)
    end

    it 'returns :lucid at 0.75' do
      s = described_class.new(theme: :test, content: 'x', lucidity_level: 0.75)
      expect(s.lucidity_label).to eq(:lucid)
    end

    it 'returns :fully_lucid at 0.9' do
      s = described_class.new(theme: :test, content: 'x', lucidity_level: 0.9)
      expect(s.lucidity_label).to eq(:fully_lucid)
    end
  end

  describe '#reality_test!' do
    it 'raises ArgumentError for unknown test type' do
      expect { state.reality_test!(:unknown) }.to raise_error(ArgumentError)
    end

    it 'records the test in reality_tests_performed' do
      allow(state).to receive(:rand).and_return(0.5) # above FALSE_AWAKENING_CHANCE threshold
      state.reality_test!(:hand_check)
      expect(state.reality_tests_performed.size).to eq(1)
      expect(state.reality_tests_performed.first[:test_type]).to eq(:hand_check)
    end

    it 'increases lucidity_level on successful test' do
      allow(state).to receive(:rand).and_return(0.5)
      prev = state.lucidity_level
      state.reality_test!(:hand_check)
      expect(state.lucidity_level).to be > prev
    end

    it 'sets awareness to true after gaining lucidity' do
      allow(state).to receive(:rand).and_return(0.5)
      state.reality_test!(:hand_check)
      expect(state.awareness).to be true
    end

    it 'detects false awakenings when rand < FALSE_AWAKENING_CHANCE' do
      allow(state).to receive(:rand).and_return(0.05)
      result = state.reality_test!(:hand_check)
      expect(result[:false_awakening]).to be true
      expect(result[:outcome]).to eq(:false_awakening)
      expect(state.false_awakening_count).to eq(1)
    end

    it 'clamps lucidity at 1.0' do
      s = described_class.new(theme: :test, content: 'x', lucidity_level: 0.95)
      allow(s).to receive(:rand).and_return(0.5)
      s.reality_test!(:hand_check)
      expect(s.lucidity_level).to be <= 1.0
    end

    it 'returns a result hash with outcome key' do
      allow(state).to receive(:rand).and_return(0.5)
      result = state.reality_test!(:text_stability)
      expect(result).to have_key(:outcome)
    end
  end

  describe '#steer!' do
    it 'returns failure when lucidity < 0.5' do
      result = state.steer!(:become_ocean)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:insufficient_lucidity)
    end

    it 'steers dream successfully when lucidity >= 0.5' do
      s = described_class.new(theme: :test, content: 'original', lucidity_level: 0.7)
      result = s.steer!(:transform_into_forest)
      expect(result[:success]).to be true
      expect(s.content).to include('transform_into_forest')
      expect(s.steered).to be true
    end

    it 'reduces stability slightly after steering' do
      s = described_class.new(theme: :test, content: 'x', lucidity_level: 0.8, stability: 0.7)
      s.steer!(:new_scene)
      expect(s.stability).to be < 0.7
    end
  end

  describe '#destabilize!' do
    it 'reduces stability by given amount' do
      initial = state.stability
      state.destabilize!(0.2)
      expect(state.stability).to be_within(0.001).of(initial - 0.2)
    end

    it 'decays lucidity by LUCIDITY_DECAY constant' do
      s = described_class.new(theme: :test, content: 'x', lucidity_level: 0.5)
      s.destabilize!(0.1)
      expect(s.lucidity_level).to be_within(0.001).of(0.5 - Legion::Extensions::CognitiveLucidity::Helpers::Constants::LUCIDITY_DECAY)
    end

    it 'clamps stability at 0.0' do
      state.destabilize!(2.0)
      expect(state.stability).to eq(0.0)
    end
  end

  describe '#stabilize!' do
    it 'increases stability by given amount' do
      s = described_class.new(theme: :test, content: 'x', stability: 0.3)
      s.stabilize!(0.2)
      expect(s.stability).to be_within(0.001).of(0.5)
    end

    it 'clamps stability at 1.0' do
      state.stabilize!(5.0)
      expect(state.stability).to eq(1.0)
    end
  end

  describe '#end!' do
    it 'marks state as inactive' do
      state.end!
      expect(state.active?).to be false
    end

    it 'sets ended_at timestamp' do
      state.end!
      expect(state.ended_at).to be_a(Time)
    end
  end

  describe '#duration_seconds' do
    it 'returns positive duration' do
      state.end!
      expect(state.duration_seconds).to be >= 0
    end

    it 'returns duration even if not ended' do
      expect(state.duration_seconds).to be >= 0
    end
  end
end
