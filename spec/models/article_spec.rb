require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'concerns' do
    # Эта строка запускает все тесты из `publishable_examples.rb`
    it_behaves_like "a publishable model"

    # Эта строка запускает тесты из `taggable_examples.rb`
    it_behaves_like "a taggable model"

    # Для `sluggable` нужно передать, какое поле является источником слага
    it_behaves_like "a sluggable model" do
      let(:source_attribute) { :title }
    end
  end

  # Здесь можно добавить тесты, специфичные только для Article, если они появятся
end
