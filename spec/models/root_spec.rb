require 'rails_helper'

RSpec.describe Root, type: :model do
  describe 'validations' do
    context 'uniqueness of text per language' do
      let(:language) { create(:language) }

      before do
        create(:root, text: 'lar', language: language)
      end

      it 'is invalid with a duplicate text in the same language' do
        expect(build(:root, text: 'lar', language: language)).not_to be_valid
      end

      it 'is valid with the same text in a different language' do
        different_language = create(:language)
        expect(build(:root, text: 'lar', language: different_language)).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:language) }
    it { should belong_to(:author) }
    it { should have_one(:etymology) }
  end

  describe 'scopes' do
    # `let!` создает записи до выполнения теста
    let!(:root1) { create(:root, text: 'lar', meaning: 'love, death') }
    let!(:root2) { create(:root, text: 'vor', meaning: 'path, way') }

    it '.search_by_text returns roots matching text' do
      results = described_class.search_by_text('lar')
      expect(results).to include(root1)
      expect(results).not_to include(root2)
    end

    it '.search_by_text returns roots matching meaning' do
      results = described_class.search_by_text('love')
      expect(results).to include(root1)
      expect(results).not_to include(root2)
    end
  end

  describe 'concerns' do
    it 'is publishable' do
      # Простая проверка, что консерн подключен.
      # Саму логику консерна мы протестируем отдельно.
      expect(described_class.new).to respond_to(:published?)
    end

    it 'is sluggable' do
      root = create(:root, text: "k'e")
      expect(root.slug).to eq("k-e")
    end
  end
end
