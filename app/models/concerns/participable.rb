module Participable
  extend ActiveSupport::Concern

  included do
    # `as: :participant` говорит Rails, что эта модель может быть "участником"
    # в полиморфной связи
    has_many :participations, class_name: "Timeline::Participation",
             as: :participant,
             dependent: :destroy

    has_many :history_entries, through: :participations
  end
end
