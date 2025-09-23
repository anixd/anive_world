require 'rails_helper'

RSpec.describe HistoryEntry, type: :model do
  describe 'concerns' do
    # Переиспользуем общие тесты
    it_behaves_like "a publishable model"
    it_behaves_like "a taggable model"
    it_behaves_like "a sluggable model" do
      let(:source_attribute) { :title }
    end
  end

  describe 'associations' do
    it { should belong_to(:era).optional }
    it { should have_many(:participations).dependent(:destroy) }
    it { should have_many(:participating_characters) }
    it { should have_many(:participating_locations) }

    it 'can have different types of participants' do
      history_entry = create(:history_entry)
      character = create(:character)
      location = create(:location)

      history_entry.participations.create!(participant: character)
      history_entry.participations.create!(participant: location)

      history_entry.reload

      # Метод participants должен вернуть оба объекта
      expect(history_entry.participants).to contain_exactly(character, location)
    end
  end

  describe 'callbacks' do
    describe '#set_form_date_fields' do
      # Создаем календарь, от которого будет идти расчет
      let!(:calendar) { create(:timeline_calendar, absolute_year_of_epoch: 5322) }

      it 'populates virtual date attributes after being found' do
        # Создаем запись с конкретным абсолютным годом
        entry = create(:history_entry, absolute_year: 7033)

        # `after_initialize` срабатывает при загрузке из БД, поэтому "находим" ее заново
        persisted_entry = described_class.find(entry.id)

        # Проверяем, что виртуальные поля заполнились правильными значениями
        # 7033 - (5322 - 1) = 1712
        expect(persisted_entry.year).to eq(1712)
        expect(persisted_entry.is_before_epoch).to be(false)
        expect(persisted_entry.calendar_id).to eq(calendar.id)
      end
    end
  end
end
