# frozen_string_literal: true

class ExportPolicy < ApplicationPolicy
  def show?
    user.owner? || user.author?
  end

  def dictionary?
    show?
  end
end
