# frozen_string_literal: true

class ContentEntryPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # В админке (forge) все залогиненные пользователи могут видеть список всех записей
      # (согласно матрице). Для публичной части здесь будет другая логика.
      scope.all
    end
  end

  def show?
    # Запись видна, если:
    # 1. Она опубликована (это правило для всех, включая Гостей).
    # ИЛИ
    # 2. Пользователь авторизован (любая роль от Neophyte до Root).
    record.published? || user.present?
  end

  def show_preview?
    show?
  end

  def create?
    user.present?
  end

  def update?
    return false unless user.present?
    record.author == user || user.editor? || user.author? || user.owner? || user.root?
  end

  def destroy?
    return false unless user.present?
    # Только "старшие" роли.
    user.author? || user.owner? || user.root?
  end

  def publish?
    destroy?
  end
end
