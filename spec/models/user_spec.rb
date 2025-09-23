require 'rails_helper'

RSpec.describe User, type: :model do
  # `describe` группирует тесты для определенного аспекта модели
  describe 'validations' do
    # `subject` определяет объект, который мы тестируем в этой группе
    subject { build(:user) }

    # `it` - это сам тест-кейс
    it 'is valid with valid attributes' do
      # `expect(...).to be_valid` - это утверждение (assertion).
      # Мы ожидаем, что объект, созданный фабрикой, будет валидным.
      expect(subject).to be_valid
    end

    it 'is invalid without a username' do
      subject.username = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid with a short username' do
      subject.username = 'aa'
      expect(subject).not_to be_valid
    end

    it 'is invalid with a duplicate email' do
      # `create(:user)` создает и сохраняет пользователя в тестовую БД
      create(:user, email: 'test@anive.org')
      # `build(:user)` создает объект в памяти, но не сохраняет
      user_with_duplicate_email = build(:user, email: 'test@anive.org')

      expect(user_with_duplicate_email).not_to be_valid
    end

    # ... другие тесты для остальных валидаций (firstname, lastname, email)
  end

  describe 'roles' do
    it 'defaults to neophyte role upon creation' do
      user = create(:user)
      # Проверяем, что enum работает и значение по умолчанию верное
      expect(user.neophyte?).to be(true)
    end

    it 'can be created with an author role' do
      # Используем трейт :author, который мы определили в фабрике
      author_user = create(:user, :author)
      expect(author_user.author?).to be(true)
    end
  end

  describe '#can_manage_user_role?' do
    let(:author) { create(:user, :author) }
    let(:editor) { create(:user, :editor) }
    let(:neophyte) { create(:user, :neophyte) }

    it 'allows a higher role to manage a lower role' do
      expect(author.can_manage_user_role?(editor)).to be(true)
    end

    it 'does not allow a lower role to manage a higher role' do
      expect(editor.can_manage_user_role?(author)).to be(false)
    end

    it 'does not allow a role to manage a role of the same level' do
      another_author = create(:user, :author)
      expect(author.can_manage_user_role?(another_author)).to be(false)
    end
  end
end
