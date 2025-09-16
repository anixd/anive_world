# frozen_string_literal: true

module Participable
  extend ActiveSupport::Concern

  included do
    has_many :participations, class_name: "Timeline::Participation",
             as: :participant,
             dependent: :destroy

    has_many :history_entries, through: :participations
  end
end
