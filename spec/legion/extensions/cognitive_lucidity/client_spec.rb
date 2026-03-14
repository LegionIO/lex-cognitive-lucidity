# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLucidity::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a LucidityEngine by default' do
      expect(client.send(:default_engine)).to be_a(
        Legion::Extensions::CognitiveLucidity::Helpers::LucidityEngine
      )
    end

    it 'accepts an injected engine' do
      custom = Legion::Extensions::CognitiveLucidity::Helpers::LucidityEngine.new
      c      = described_class.new(engine: custom)
      expect(c.send(:default_engine)).to be(custom)
    end
  end

  describe 'runner inclusion' do
    it 'responds to begin_dream' do
      expect(client).to respond_to(:begin_dream)
    end

    it 'responds to reality_test' do
      expect(client).to respond_to(:reality_test)
    end

    it 'responds to steer_dream' do
      expect(client).to respond_to(:steer_dream)
    end

    it 'responds to end_dream' do
      expect(client).to respond_to(:end_dream)
    end

    it 'responds to lucidity_status' do
      expect(client).to respond_to(:lucidity_status)
    end

    it 'responds to journal_entries' do
      expect(client).to respond_to(:journal_entries)
    end
  end

  describe 'full workflow' do
    it 'begins a dream, runs a reality test, steers it, and ends it' do
      begin_result  = client.begin_dream(theme: :underwater, content: 'coral reef')
      dream_id      = begin_result[:dream_id]

      expect(begin_result[:success]).to be true

      status = client.lucidity_status
      expect(status[:active_dream]).not_to be_nil

      engine = client.send(:default_engine)
      state  = engine.all_dreams.find { |d| d.id == dream_id }

      # Force enough lucidity to steer
      10.times do
        allow(state).to receive(:rand).and_return(0.5)
        state.reality_test!(:hand_check)
      end

      steer_result = client.steer_dream(dream_id: dream_id, direction: :transform_into_forest)
      expect(steer_result[:success]).to be true

      end_result = client.end_dream(dream_id: dream_id, insights: ['became aware in dream'])
      expect(end_result[:success]).to be true

      journal = client.journal_entries
      expect(journal[:count]).to eq(1)
      expect(journal[:entries].first[:insights]).to include('became aware in dream')
    end
  end
end
