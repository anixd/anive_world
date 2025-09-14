class TimelinePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Only high-level users can see these lists
      user.can_manage_all_content? ? scope.all : scope.none
    end
  end

  def index?
    user.can_manage_all_content?
  end

  def show?
    user.can_manage_all_content?
  end

  def create?
    user.can_manage_all_content?
  end

  def update?
    user.can_manage_all_content?
  end

  def destroy?
    user.can_manage_all_content?
  end
end