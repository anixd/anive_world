require "anike-slugify"

class SlugGenerator
  def self.call(text, preserve_affixes: true)
    return "slug-#{SecureRandom.hex(3)}" if text.blank?

    text.to_s
        .to_anike_slug
        .transliterate(:russian) # TODO make language optional param
        .normalize(preserve_affixes: preserve_affixes)
        .to_s
  end

  def self.debug(text)
    puts "Original: #{text.inspect}"
    puts "After to_slug: #{text.to_s.to_slug}"
    puts "After transliterate: #{text.to_s.to_slug.transliterate(:russian)}"
    puts "After normalize_anike: #{text.to_s.to_slug.transliterate(:russian).normalize_anike}"
    puts "Final: #{call(text)}"
  end
end
