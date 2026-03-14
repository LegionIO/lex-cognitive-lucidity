# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLucidity::Helpers::Constants do
  describe 'MAX_JOURNAL_ENTRIES' do
    it 'is 500' do
      expect(described_class::MAX_JOURNAL_ENTRIES).to eq(500)
    end
  end

  describe 'MAX_DREAMS' do
    it 'is 100' do
      expect(described_class::MAX_DREAMS).to eq(100)
    end
  end

  describe 'LUCIDITY_LEVELS' do
    it 'contains five levels in order' do
      expect(described_class::LUCIDITY_LEVELS).to eq(%i[non_lucid pre_lucid semi_lucid lucid fully_lucid])
    end

    it 'is frozen' do
      expect(described_class::LUCIDITY_LEVELS).to be_frozen
    end
  end

  describe 'REALITY_TEST_TYPES' do
    it 'contains the expected test types' do
      expect(described_class::REALITY_TEST_TYPES).to include(
        :text_stability, :hand_check, :time_check, :memory_check, :logic_check
      )
    end

    it 'is frozen' do
      expect(described_class::REALITY_TEST_TYPES).to be_frozen
    end
  end

  describe 'LUCIDITY_DECAY' do
    it 'is 0.05' do
      expect(described_class::LUCIDITY_DECAY).to eq(0.05)
    end
  end

  describe 'FALSE_AWAKENING_CHANCE' do
    it 'is 0.1' do
      expect(described_class::FALSE_AWAKENING_CHANCE).to eq(0.1)
    end
  end

  describe 'DREAM_QUALITY_LABELS' do
    it 'maps ranges to quality labels' do
      expect(described_class::DREAM_QUALITY_LABELS.values).to include(:poor, :ordinary, :vivid, :hyper_vivid)
    end

    it 'is frozen' do
      expect(described_class::DREAM_QUALITY_LABELS).to be_frozen
    end
  end

  describe '.label_for' do
    it 'returns :poor for value 0.1' do
      expect(described_class.label_for(0.1)).to eq(:poor)
    end

    it 'returns :fragmented for value 0.3' do
      expect(described_class.label_for(0.3)).to eq(:fragmented)
    end

    it 'returns :ordinary for value 0.5' do
      expect(described_class.label_for(0.5)).to eq(:ordinary)
    end

    it 'returns :vivid for value 0.7' do
      expect(described_class.label_for(0.7)).to eq(:vivid)
    end

    it 'returns :hyper_vivid for value 0.9' do
      expect(described_class.label_for(0.9)).to eq(:hyper_vivid)
    end

    it 'clamps values above 1.0' do
      expect(described_class.label_for(1.5)).to eq(:hyper_vivid)
    end

    it 'clamps values below 0.0' do
      expect(described_class.label_for(-0.5)).to eq(:poor)
    end
  end
end
