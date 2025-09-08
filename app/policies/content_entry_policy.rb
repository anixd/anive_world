# Базовый класс для всех моделей, унаследованных от ContentEntry.
class ContentEntryPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  # Просмотр делаем публичным, так как это контент для сайта
  def show?
    true
  end

  # Создавать могут все залогиненные
  def create?
    user.present?
  end

  # Редактировать могут старшие роли или автор
  def update?
    user.can_manage_all_content? || record.author == user
  end

  # Удалять могут только root и author, согласно матрице
  def destroy?
    user.root? || user.author?
  end

  # --- Кастомные правила ---

  # Публиковать напрямую могут owner и author
  def publish?
    user.can_publish_directly?
  end

  # Снимать с публикации могут только root и author
  def unpublish?
    user.root? || user.author?
  end
end
