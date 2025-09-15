class WikilinkResolver
  TYPE_ALIASES = {
    "w" => Lexeme, "word" => Lexeme,
    "a" => Article, "article" => Article,
    "h" => HistoryEntry, "history" => HistoryEntry,
    "c" => Character, "character" => Character,
    "l" => Location, "location" => Location,
    "g" => GrammarRule, "grammar" => GrammarRule,
    "p" => PhonologyArticle, "phonology" => PhonologyArticle
  }.freeze

  LANGUAGE_ALIASES = {
    "a" => "anike", "anike" => "anike",
    "d" => "drelen", "drelen" => "drelen",
    "v" => "veltari", "veltari" => "veltari"
  }.freeze


  # def self.resolve(type_alias, lang_alias, identifier)
  #   model = TYPE_ALIASES[type_alias]
  #   return nil unless model
  #
  #   generated_slug = SlugGenerator.call(identifier)
  #
  #   if model == Lexeme
  #     lang_code = LANGUAGE_ALIASES[lang_alias]
  #     return nil unless lang_code
  #     language = Language.find_by(code: lang_code)
  #     return nil unless language
  #
  #     # Цепочка поиска для Лексем:
  #     # 1. По прямому совпадению слага
  #     record = model.find_by(slug: identifier, language: language)
  #     # 2. По сгенерированному слагу
  #     record ||= model.find_by(slug: generated_slug, language: language)
  #     # 3. По точному совпадению написания (spelling)
  #     record ||= model.find_by(spelling: identifier, language: language)
  #     record
  #   else
  #     # Цепочка поиска для остального контента:
  #     # 1. По прямому совпадению slug
  #     record = model.find_by(slug: identifier)
  #     # 2. По сгенерированному slug
  #     record ||= model.find_by(slug: generated_slug)
  #     # 3. По точному совпадению заголовка (title)
  #     record ||= model.find_by(title: identifier)
  #     record
  #   end
  # end

  def self.resolve(type_alias, lang_alias, identifier)
    model = TYPE_ALIASES[type_alias]
    return nil unless model

    generated_slug = SlugGenerator.call(identifier)

    if model == Lexeme
      lang_code = LANGUAGE_ALIASES[lang_alias]
      return nil unless lang_code
      language = Language.find_by(code: lang_code)
      return nil unless language

      record = model.find_by(slug: identifier, language: language)
      record ||= model.find_by(slug: generated_slug, language: language)
      # Шаг 3: Ищем по написанию (spelling) без учета регистра
      record ||= model.where("spelling ILIKE ?", identifier).where(language: language).first
      record
    else
      record = model.find_by(slug: identifier)
      record ||= model.find_by(slug: generated_slug)
      # Шаг 3: Ищем по заголовку (title) без учета регистра
      record ||= model.where("title ILIKE ?", identifier).first
      record
    end
  end

  def self.path_for(record)
    Rails.application.routes.url_helpers.url_for([:forge, record, only_path: true])
  rescue NoMethodError
    "#"
  end
end
