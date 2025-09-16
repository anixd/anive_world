# frozen_string_literal: true

module Shareable
  extend ActiveSupport::Concern
  included do
    has_many :shares, as: :shareable, dependent: :destroy
    has_many :shared_with_users, through: :shares, source: :user
  end
end
