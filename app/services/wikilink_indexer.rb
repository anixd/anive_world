class WikilinkIndexer
  WIKILINK_REGEX = /\[\[(\w+):(?:(\w+):)?([^\]|]+)(?:\|([^\]]+))?\]\]/

  def self.call(record)
    new(record).call
  end

  def initialize(record)
    @record = record
  end

  def call
    ActiveRecord::Base.transaction do
      @record.wikilinks.destroy_all
      links_to_create = parse_links_from(content_to_scan)
      Wikilink.insert_all(links_to_create) if links_to_create.any?
    end
  end

  private

  def content_to_scan
    @record.class.columns
           .select { |c| c.type == :text }
           .map { |c| @record.send(c.name).to_s }
           .join("\n")
  end

  def parse_links_from(text)
    text.scan(WIKILINK_REGEX).map do |section_alias, lang_alias, identifier, _|
      {
        source_type: @record.class.base_class.name,
        source_id: @record.id,
        target_slug: identifier.strip,
        target_type: section_alias.downcase,
        target_language_code: lang_alias&.downcase,
        created_at: Time.current,
        updated_at: Time.current
      }
    end.uniq
  end
end
