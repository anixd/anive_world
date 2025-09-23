RSpec.shared_examples "a taggable model" do
  let(:model_factory) { described_class.model_name.singular.to_sym }

  describe '#tags_string=' do
    # `let(:record)` будет пересоздаваться для каждого теста `it`
    let(:record) { create(model_factory) }

    it 'creates and associates tags with apostrophes and cyrillic characters' do
      record.tags_string = "anik'e, идиомы, k'ethari"
      expect(record.tags.count).to eq(3)
      expect(record.tags.map(&:name)).to contain_exactly("anik'e", "идиомы", "k'ethari")
    end

    it 'handles comma, pipe and extra spaces as separators' do
      record.tags_string = 'war,  magic | art'
      expect(record.tags.map(&:name)).to contain_exactly('war', 'magic', 'art')
    end

    it 'handles only spaces as separators' do
      record.tags_string = "персонаж главный герой"
      expect(record.tags.map(&:name)).to contain_exactly("персонаж", "главный", "герой")
    end

    it 'reuses existing tags and does not create duplicates' do
      # Создаем один тег заранее
      existing_tag = create(:tag, name: 'идиомы')

      # Ожидаем, что будет создан только один новый тег ('k'ethari')
      expect {
        record.tags_string = "идиомы, k'ethari"
      }.to change(Tag, :count).by(1)

      # Проверяем, что оба тега (старый и новый) связаны с записью
      expect(record.tags).to include(existing_tag)
      expect(record.tags.map(&:name)).to contain_exactly('идиомы', "k'ethari")
    end
  end
end
