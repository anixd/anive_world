# frozen_string_literal: true

module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
    scope :drafts, -> { where(published_at: nil).or(where("published_at > ?", Time.current)) }
  end

  def publish
    published?
  end

  def publish=(value)
    if %w[1 true].include?(value.to_s)
      self.published_at ||= Time.current
    else
      self.published_at = nil
    end
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  def scheduled?
    published_at.present? && published_at > Time.current
  end
end
