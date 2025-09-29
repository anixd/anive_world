# frozen_string_literal: true

class LanguagePolicy < LinguisticPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  def show?
    user.present?
  end
end
