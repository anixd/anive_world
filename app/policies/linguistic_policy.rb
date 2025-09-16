# frozen_string_literal: true

class LinguisticPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  def show?
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

    user.author? || user.owner? || user.root?
  end

  def publish?
    destroy?
  end
end
