require 'rails_helper'

RSpec.describe Word, type: :model do
  describe 'associations' do
    it { should belong_to(:lexeme) }
    it { should have_and_belong_to_many(:parts_of_speech) }
    it { should have_one(:etymology).dependent(:destroy) }
  end

  describe 'callbacks' do
    context 'before_validation #set_sti_type' do
      it 'sets the correct STI type based on language code on create' do
        # Создаем язык с предсказуемым кодом
        language = create(:language, code: 'anike')
        lexeme = create(:lexeme, language: language)

        # `build` не вызывает коллбэки сохранения, только `create`
        word = build(:word, lexeme: lexeme)

        # Тип еще не должен быть установлен
        expect(word.type).to be_nil

        # Сохраняем, чтобы сработал коллбэк
        word.save!

        # Проверяем результат
        expect(word.type).to eq('AnikeWord')
      end
    end
  end
end
