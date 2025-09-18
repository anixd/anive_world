# frozen_string_literal: true

# == Schema Information
#
# Table name: content_entries
#
#  id                 :bigint           not null, primary key
#  absolute_year      :integer
#  annotation         :text
#  birth_date         :string
#  body               :text
#  death_date         :string
#  discarded_at       :datetime
#  display_date       :string
#  extract            :text
#  life_status        :string
#  published_at       :datetime
#  rule_code          :string
#  searchable         :tsvector
#  slug               :string           not null
#  title              :string           not null
#  type               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :bigint           not null
#  era_id             :bigint
#  language_id        :bigint
#  parent_location_id :bigint
#
# Indexes
#
#  content_entries_searchable_idx                 (searchable) USING gin
#  index_content_entries_on_absolute_year         (absolute_year)
#  index_content_entries_on_author_id             (author_id)
#  index_content_entries_on_discarded_at          (discarded_at)
#  index_content_entries_on_era_id                (era_id)
#  index_content_entries_on_language_id           (language_id)
#  index_content_entries_on_parent_location_id    (parent_location_id)
#  index_content_entries_on_slug                  (slug) UNIQUE WHERE (discarded_at IS NULL)
#  index_content_entries_on_type                  (type)
#  index_content_entries_on_type_and_lower_title  (type, lower((title)::text))
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (era_id => timeline_eras.id)
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (parent_location_id => content_entries.id)
#

class HistoryEntry < ContentEntry
  include Participable

  attr_accessor :calendar_id, :year, :is_before_epoch

  belongs_to :era, class_name: "Timeline::Era", optional: true

  has_many :participations, class_name: "Timeline::Participation", dependent: :destroy
  has_many :participants, through: :participations, source: :participant

  after_initialize :set_form_date_fields, if: :persisted?

  private

  def set_form_date_fields
    return unless absolute_year.present?

    # Используем первый календарь как календарь "по умолчанию"
    default_calendar = Timeline::Calendar.order(:id).first
    return unless default_calendar

    # Инициализируем конвертер
    converter = Timeline::TimeConverter.new
    # Получаем "запчасти" даты от сервиса
    date_parts = converter.from_absolute_parts(absolute_year: self.absolute_year, to_calendar_id: default_calendar.id)

    # Заполняем виртуальные атрибуты
    if date_parts
      self.calendar_id = default_calendar.id
      self.year = date_parts[:year]
      self.is_before_epoch = date_parts[:is_before_epoch]
    end
  end
end
