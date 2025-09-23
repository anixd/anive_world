require 'rails_helper'

RSpec.describe Language, type: :model do
  describe 'validations' do
    # `subject` здесь - это объект, созданный нашей новой фабрикой :language
    subject { build(:language) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without a code' do
      subject.code = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without an author' do
      subject.author = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid with a duplicate name' do
      create(:language, name: 'Elvish')
      subject.name = 'Elvish'
      expect(subject).not_to be_valid
    end

    it 'is invalid with a duplicate code' do
      create(:language, code: 'elv')
      subject.code = 'elv'
      expect(subject).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to an author' do
      # `reflect_on_association` - встроенный метод RSpec для проверки связей
      association = described_class.reflect_on_association(:author)
      expect(association.macro).to eq :belongs_to
    end

    it 'can have a parent language' do
      parent_language = create(:language)
      child_language = create(:language, parent_language: parent_language)

      # Проверяем, что связь установилась в обоих направлениях
      expect(child_language.parent_language).to eq(parent_language)
      expect(parent_language.child_languages).to include(child_language)
    end

    it 'can have many lexemes' do
      association = described_class.reflect_on_association(:lexemes)
      expect(association.macro).to eq :has_many
    end

    it 'can have many roots' do
      association = described_class.reflect_on_association(:roots)
      expect(association.macro).to eq :has_many
    end

    it 'can have many affixes' do
      association = described_class.reflect_on_association(:affixes)
      expect(association.macro).to eq :has_many
    end

    it 'can have many parts_of_speech' do
      association = described_class.reflect_on_association(:parts_of_speech)
      expect(association.macro).to eq :has_many
    end
  end
end
