require 'rails_helper'

RSpec.describe Lexeme, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:lexeme)).to be_valid
    end

    it 'is invalid without spelling' do
      expect(build(:lexeme, spelling: nil)).not_to be_valid
    end

    it 'is invalid without a language' do
      expect(build(:lexeme, language: nil)).not_to be_valid
    end

    context 'uniqueness of spelling per language' do
      let(:language1) { create(:language) }
      let(:language2) { create(:language) }

      before do
        create(:lexeme, spelling: 'duil', language: language1)
      end

      it 'is invalid with a duplicate spelling in the same language' do
        expect(build(:lexeme, spelling: 'duil', language: language1)).not_to be_valid
      end

      it 'is valid with the same spelling in a different language' do
        expect(build(:lexeme, spelling: 'duil', language: language2)).to be_valid
      end
    end
  end

  describe 'associations' do
    # Создаем язык, который реально существует в логике приложения
    let(:language) { create(:language, code: 'anike') }
    # `let!` с восклицательным знаком означает, что лексема будет создана
    # до выполнения каждого теста в этом блоке (`it`)
    let!(:lexeme) { create(:lexeme, :with_words, language: language) }

    it 'destroys associated words when destroyed' do
      # Убеждаемся, что для теста созданы правильные объекты
      expect(Word.count).to be > 0
      expect(lexeme.words.first.type).to eq('AnikeWord')

      # Проверяем, что при удалении лексемы, связанные слова тоже удаляются.
      expect { lexeme.destroy }.to change { Word.count }.by(-4)
    end
  end
end
