# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLucidity::Helpers::LucidityEngine do
  subject(:engine) { described_class.new }

  def start_dream(theme: :forest, content: 'walking through trees', **)
    engine.begin_dream(theme: theme, content: content, **)
  end

  describe '#begin_dream' do
    it 'returns a dream_id' do
      result = start_dream
      expect(result[:dream_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'returns the theme' do
      result = start_dream(theme: :ocean)
      expect(result[:theme]).to eq(:ocean)
    end

    it 'returns initial lucidity_level' do
      result = start_dream(lucidity_level: 0.3)
      expect(result[:lucidity_level]).to eq(0.3)
    end

    it 'returns initial stability' do
      result = start_dream(stability: 0.6)
      expect(result[:stability]).to eq(0.6)
    end

    it 'stores the dream state internally' do
      result = start_dream
      expect(engine.all_dreams.map(&:id)).to include(result[:dream_id])
    end

    it 'evicts oldest dream when MAX_DREAMS exceeded' do
      stub_const('Legion::Extensions::CognitiveLucidity::Helpers::Constants::MAX_DREAMS', 2)
      r1 = start_dream(theme: :a, content: 'x')
      start_dream(theme: :b, content: 'y')
      start_dream(theme: :c, content: 'z')

      ids = engine.all_dreams.map(&:id)
      expect(ids).not_to include(r1[:dream_id])
    end
  end

  describe '#reality_test' do
    let(:dream_id) { start_dream[:dream_id] }

    it 'returns success: false for unknown dream_id' do
      result = engine.reality_test(dream_id: 'nonexistent', test_type: :hand_check)
      expect(result[:success]).to be false
    end

    it 'returns a result with outcome key on valid test' do
      result = engine.reality_test(dream_id: dream_id, test_type: :hand_check)
      expect(result).to have_key(:outcome)
    end

    it 'returns success: false for unknown test type' do
      result = engine.reality_test(dream_id: dream_id, test_type: :unknown_test)
      expect(result[:success]).to be false
    end

    it 'includes current lucidity_level in result' do
      result = engine.reality_test(dream_id: dream_id, test_type: :time_check)
      expect(result).to have_key(:lucidity_level)
    end

    it 'returns success: false for inactive dream' do
      engine.end_dream(dream_id: dream_id)
      result = engine.reality_test(dream_id: dream_id, test_type: :hand_check)
      expect(result[:success]).to be false
    end
  end

  describe '#steer_dream' do
    it 'returns success: false for unknown dream_id' do
      result = engine.steer_dream(dream_id: 'nonexistent', direction: :fly)
      expect(result[:success]).to be false
    end

    it 'returns success: false when lucidity is too low' do
      dream_id = start_dream(lucidity_level: 0.0)[:dream_id]
      result = engine.steer_dream(dream_id: dream_id, direction: :fly)
      expect(result[:success]).to be false
    end

    it 'succeeds when lucidity >= 0.5' do
      dream_id = start_dream(lucidity_level: 0.6)[:dream_id]
      result = engine.steer_dream(dream_id: dream_id, direction: :become_underwater)
      expect(result[:success]).to be true
    end

    it 'includes dream_id in result' do
      dream_id = start_dream(lucidity_level: 0.6)[:dream_id]
      result = engine.steer_dream(dream_id: dream_id, direction: :new_scene)
      expect(result[:dream_id]).to eq(dream_id)
    end
  end

  describe '#end_dream' do
    let(:dream_id) { start_dream[:dream_id] }

    it 'returns success: true' do
      result = engine.end_dream(dream_id: dream_id)
      expect(result[:success]).to be true
    end

    it 'returns a journal_entry_id' do
      result = engine.end_dream(dream_id: dream_id)
      expect(result[:journal_entry_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'creates a journal entry' do
      engine.end_dream(dream_id: dream_id)
      expect(engine.journal).not_to be_empty
    end

    it 'stores provided insights in journal entry' do
      engine.end_dream(dream_id: dream_id, insights: ['insight one'])
      expect(engine.journal.last.insights).to include('insight one')
    end

    it 'returns success: false for unknown dream_id' do
      result = engine.end_dream(dream_id: 'nonexistent')
      expect(result[:success]).to be false
    end

    it 'returns success: false for already-ended dream' do
      engine.end_dream(dream_id: dream_id)
      result = engine.end_dream(dream_id: dream_id)
      expect(result[:success]).to be false
    end

    it 'caps journal at MAX_JOURNAL_ENTRIES' do
      stub_const('Legion::Extensions::CognitiveLucidity::Helpers::Constants::MAX_JOURNAL_ENTRIES', 2)
      3.times do
        id = start_dream[:dream_id]
        engine.end_dream(dream_id: id)
      end
      expect(engine.journal.size).to be <= 2
    end
  end

  describe '#active_dream' do
    it 'returns nil when no active dream' do
      expect(engine.active_dream).to be_nil
    end

    it 'returns the active dream state' do
      start_dream
      expect(engine.active_dream).not_to be_nil
    end

    it 'returns nil after dream ends' do
      dream_id = start_dream[:dream_id]
      engine.end_dream(dream_id: dream_id)
      expect(engine.active_dream).to be_nil
    end
  end

  describe '#all_dreams' do
    it 'returns an empty array initially' do
      expect(engine.all_dreams).to be_empty
    end

    it 'returns all dream states including ended ones' do
      dream_id = start_dream[:dream_id]
      engine.end_dream(dream_id: dream_id)
      expect(engine.all_dreams.size).to eq(1)
    end
  end

  describe '#lucidity_report' do
    context 'with no journal entries' do
      it 'returns zero counts' do
        report = engine.lucidity_report
        expect(report[:total_dreams]).to eq(0)
        expect(report[:avg_lucidity]).to eq(0.0)
        expect(report[:false_awakening_count]).to eq(0)
      end
    end

    context 'with journal entries' do
      before do
        dream_id = start_dream(lucidity_level: 0.5)[:dream_id]
        engine.end_dream(dream_id: dream_id)
      end

      it 'returns correct total_dreams' do
        expect(engine.lucidity_report[:total_dreams]).to eq(1)
      end

      it 'returns avg_lucidity as a float' do
        expect(engine.lucidity_report[:avg_lucidity]).to be_a(Float)
      end

      it 'includes false_awakening_count' do
        expect(engine.lucidity_report).to have_key(:false_awakening_count)
      end

      it 'includes steered_count' do
        expect(engine.lucidity_report).to have_key(:steered_count)
      end
    end
  end

  describe '#most_lucid_dreams' do
    before do
      low_id  = start_dream(lucidity_level: 0.2, theme: :low)[:dream_id]
      high_id = start_dream(lucidity_level: 0.9, theme: :high)[:dream_id]
      engine.end_dream(dream_id: low_id)
      engine.end_dream(dream_id: high_id)
    end

    it 'returns most lucid dreams first' do
      results = engine.most_lucid_dreams(limit: 2)
      expect(results.first[:lucidity_achieved]).to be >= results.last[:lucidity_achieved]
    end

    it 'respects the limit' do
      results = engine.most_lucid_dreams(limit: 1)
      expect(results.size).to eq(1)
    end

    it 'returns hashes' do
      results = engine.most_lucid_dreams
      results.each { |r| expect(r).to be_a(Hash) }
    end
  end

  describe '#theme_analysis' do
    before do
      id1 = start_dream(theme: :ocean, lucidity_level: 0.3)[:dream_id]
      id2 = start_dream(theme: :ocean, lucidity_level: 0.7)[:dream_id]
      id3 = start_dream(theme: :forest, lucidity_level: 0.5)[:dream_id]
      engine.end_dream(dream_id: id1)
      engine.end_dream(dream_id: id2)
      engine.end_dream(dream_id: id3)
    end

    it 'returns theme data sorted by occurrence count' do
      analysis = engine.theme_analysis
      ocean_entry = analysis.find { |t| t[:theme] == :ocean }
      expect(ocean_entry[:occurrences]).to eq(2)
    end

    it 'includes avg_lucidity per theme' do
      analysis = engine.theme_analysis
      ocean_entry = analysis.find { |t| t[:theme] == :ocean }
      expect(ocean_entry[:avg_lucidity]).to be_a(Float)
    end

    it 'returns empty array when no journal entries' do
      expect(described_class.new.theme_analysis).to be_empty
    end
  end
end
