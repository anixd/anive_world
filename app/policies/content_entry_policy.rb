class ContentEntryPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # В админке (forge) все залогиненные пользователи могут видеть список всех записей
      # (согласно матрице). Для публичной части здесь будет другая логика.
      scope.all
    end
  end

  # Кто может видеть запись/превью?
  def show?
    # Запись видна, если:
    # 1. Она опубликована (это правило для всех, включая Гостей).
    # ИЛИ
    # 2. Пользователь авторизован (любая роль от Neophyte до Root).
    record.published? || user.present?
  end

  def show_preview?
    show? # Логика просмотра и просмотра превью всегда идентична.
  end

  # Кто может создавать новые записи?
  def create?
    # Любой авторизованный пользователь (от Neophyte и выше).
    user.present?
  end

  # Кто может редактировать/обновлять запись?
  def update?
    return false unless user.present?
    # Право на редактирование есть у:
    # 1. Автора записи.
    # 2. Пользователей с ролями Editor, Author, Owner, Root.
    record.author == user || user.editor? || user.author? || user.owner? || user.root?
  end

  # Кто может архивировать/удалять запись?
  def destroy?
    return false unless user.present?
    # Только "старшие" роли.
    user.author? || user.owner? || user.root?
  end

  # Кто может публиковать/снимать с публикации?
  def publish?
    destroy? # Используем ту же логику, что и для удаления.
  end
end
