require 'rails_helper'

RSpec.describe Affix, type: :model do
  describe 'validations' do
    context 'uniqueness of text, language and affix_type' do
      let(:language) { create(:language) }

      before do
        # Создаем суффикс "-or" для языка
        create(:affix, text: '-or', language: language, affix_type: 'suffix')
      end

      it 'is invalid with a duplicate text, language and type' do
        # Пытаемся создать такой же суффикс
        expect(build(:affix, text: '-or', language: language, affix_type: 'suffix')).not_to be_valid
      end

      it 'is valid with the same text and language but different type' do
        # А вот префикс "-or" создать можно
        expect(build(:affix, text: '-or', language: language, affix_type: 'prefix')).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:language) }
    it { should belong_to(:author) }
    it { should have_one(:etymology) }
  end

  describe 'enums' do
    # Указываем, что enum работает со строковой колонкой в БД
    it do
      should define_enum_for(:affix_type)
               .with_values(prefix: "prefix", suffix: "suffix", infix: "infix")
               .backed_by_column_of_type(:string)
    end
  end

  describe 'scopes' do
    # `let!` создает записи до выполнения теста
    let!(:affix1) { create(:affix, text: '-ri', meaning: 'sun, star, light') }
    let!(:affix2) { create(:affix, text: '-el', meaning: 'path, way') }

    it '.search_by_text returns roots matching text' do
      results = described_class.search_by_text('-ri')
      expect(results).to include(affix1)
      expect(results).not_to include(affix2)
    end

    it '.search_by_text returns roots matching meaning' do
      results = described_class.search_by_text('light')
      expect(results).to include(affix1)
      expect(results).not_to include(affix2)
    end
  end
end
