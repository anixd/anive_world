# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # This ensures that on the index page, a user sees ONLY their own notes.
      scope.where(author: user)
    end
  end
  # Pundit передаёт в `user` текущего пользователя (current_user),
  # а в `record` — объект, к которому мы проверяем доступ (в данном случае, @note).

  def show?
    # 1. root может всё.
    # 2. Автор заметки может её видеть.
    # 3. Любой, кому "расшарили" эту заметку (неважно, на чтение или запись).
    user.root? || record.author == user || is_shared_with?(user, record)
  end

  def create?
    user.present?
  end

  def update?
    # 1. root может всё.
    # 2. Автор заметки может её редактировать.
    # 3. Пользователь, которому дали доступ на запись (`access_level: :write`).
    user.root? || record.author == user || is_shared_with_write_access?(user, record)
  end

  def destroy?
    # Согласно матрице, только автор и root.
    user.root? || record.author == user
  end

  private

  # Aux метод: проверяет, есть ли для этой заметки
  # хоть какая-то запись в таблице Share для данного пользователя.
  def is_shared_with?(user, note)
    # `note.shares` - это has_many :shares, as: :shareable из консерна Shareable
    note.shares.exists?(user: user)
  end

  # Aux метод: проверяет, есть ли у пользователя
  # доступ именно на запись.
  def is_shared_with_write_access?(user, note)
    # `Share.write` - это enum scope, который ищет `access_level: 1`
    note.shares.write.exists?(user: user)
  end
end
