# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLucidity::Runners::CognitiveLucidity do
  let(:engine) { Legion::Extensions::CognitiveLucidity::Helpers::LucidityEngine.new }
  let(:client) { Legion::Extensions::CognitiveLucidity::Client.new(engine: engine) }

  describe '#begin_dream' do
    it 'returns success: true' do
      result = client.begin_dream(theme: :space, content: 'floating among stars', engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns a dream_id' do
      result = client.begin_dream(theme: :space, content: 'floating', engine: engine)
      expect(result[:dream_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'returns the theme' do
      result = client.begin_dream(theme: :jungle, content: 'tall trees', engine: engine)
      expect(result[:theme]).to eq(:jungle)
    end

    it 'uses injected engine via keyword arg' do
      custom_engine = Legion::Extensions::CognitiveLucidity::Helpers::LucidityEngine.new
      result = client.begin_dream(theme: :test, content: 'x', engine: custom_engine)
      expect(custom_engine.all_dreams.map(&:id)).to include(result[:dream_id])
    end
  end

  describe '#reality_test' do
    let(:dream_id) do
      client.begin_dream(theme: :clouds, content: 'drifting', engine: engine)[:dream_id]
    end

    it 'returns a result hash' do
      result = client.reality_test(dream_id: dream_id, test_type: :hand_check, engine: engine)
      expect(result).to be_a(Hash)
    end

    it 'returns success: false for unknown test type' do
      result = client.reality_test(dream_id: dream_id, test_type: :bogus, engine: engine)
      expect(result[:success]).to be false
    end

    it 'returns success: false for unknown dream' do
      result = client.reality_test(dream_id: 'no-such-id', test_type: :hand_check, engine: engine)
      expect(result[:success]).to be false
    end

    it 'includes lucidity_level in result for valid test' do
      result = client.reality_test(dream_id: dream_id, test_type: :logic_check, engine: engine)
      expect(result).to have_key(:lucidity_level)
    end
  end

  describe '#steer_dream' do
    it 'returns success: false when lucidity too low' do
      dream_id = client.begin_dream(theme: :test, content: 'x', lucidity_level: 0.0, engine: engine)[:dream_id]
      result = client.steer_dream(dream_id: dream_id, direction: :fly, engine: engine)
      expect(result[:success]).to be false
    end

    it 'succeeds when lucidity is sufficient' do
      dream_id = client.begin_dream(theme: :test, content: 'x', lucidity_level: 0.7, engine: engine)[:dream_id]
      result = client.steer_dream(dream_id: dream_id, direction: :transform, engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns success: false for unknown dream' do
      result = client.steer_dream(dream_id: 'nope', direction: :fly, engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#end_dream' do
    let(:dream_id) do
      client.begin_dream(theme: :ocean, content: 'waves', engine: engine)[:dream_id]
    end

    it 'returns success: true' do
      result = client.end_dream(dream_id: dream_id, engine: engine)
      expect(result[:success]).to be true
    end

    it 'creates a journal entry' do
      client.end_dream(dream_id: dream_id, engine: engine)
      expect(engine.journal).not_to be_empty
    end

    it 'returns success: false for already-ended dream' do
      client.end_dream(dream_id: dream_id, engine: engine)
      result = client.end_dream(dream_id: dream_id, engine: engine)
      expect(result[:success]).to be false
    end

    it 'accepts insights keyword' do
      client.end_dream(dream_id: dream_id, insights: ['lucidity felt natural'], engine: engine)
      expect(engine.journal.last.insights).to include('lucidity felt natural')
    end
  end

  describe '#lucidity_status' do
    it 'returns success: true' do
      result = client.lucidity_status(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns nil active_dream when none active' do
      result = client.lucidity_status(engine: engine)
      expect(result[:active_dream]).to be_nil
    end

    it 'returns active_dream info when a dream is running' do
      client.begin_dream(theme: :starfield, content: 'infinite', engine: engine)
      result = client.lucidity_status(engine: engine)
      expect(result[:active_dream]).not_to be_nil
      expect(result[:active_dream]).to have_key(:lucidity_label)
    end

    it 'includes report with total_dreams' do
      result = client.lucidity_status(engine: engine)
      expect(result[:report]).to have_key(:total_dreams)
    end
  end

  describe '#journal_entries' do
    before do
      dream_id = client.begin_dream(theme: :wind, content: 'rustling', engine: engine)[:dream_id]
      client.end_dream(dream_id: dream_id, engine: engine)
    end

    it 'returns success: true' do
      result = client.journal_entries(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns a count' do
      result = client.journal_entries(engine: engine)
      expect(result[:count]).to eq(1)
    end

    it 'returns entries array' do
      result = client.journal_entries(engine: engine)
      expect(result[:entries]).to be_an(Array)
    end

    it 'respects limit param' do
      3.times do
        id = client.begin_dream(theme: :extra, content: 'x', engine: engine)[:dream_id]
        client.end_dream(dream_id: id, engine: engine)
      end
      result = client.journal_entries(limit: 2, engine: engine)
      expect(result[:entries].size).to be <= 2
    end
  end
end
