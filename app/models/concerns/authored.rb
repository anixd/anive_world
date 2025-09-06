module Authored
  extend ActiveSupport::Concern

  included do
    belongs_to :author, class_name: "User"
    validates :author, presence: true
  end
end
