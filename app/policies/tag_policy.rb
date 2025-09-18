class TagPolicy < ApplicationPolicy
  def index? = true
  def new? = true
  def create? = true
  def edit? = true
  def update? = true
  def destroy? = true
  def search? = true

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
