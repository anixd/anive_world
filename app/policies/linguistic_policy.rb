# Базовый класс для всех "лингвистических" моделей.
class LinguisticPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  # Просматривать могут все залогиненные
  def show?
    user.present?
  end

  # Создавать могут все залогиненные
  def create?
    user.present?
  end

  # Редактировать могут либо "старшие" роли (для любого объекта),
  # либо автор своей собственной записи.
  def update?
    user.can_manage_all_content? || record.author == user
  end

  # Удалять (архивировать) могут только "старшие" роли.
  def destroy?
    # В твоей матрице это root и author. Owner тоже сюда логично вписывается.
    user.can_manage_all_content?
  end
end
