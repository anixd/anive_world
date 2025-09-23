# app/services/dictionary_json_exporter.rb
class DictionaryJsonExporter
  def self.call(...)
    new(...).call
  end

  def initialize(language_id:, fields: [], pretty: true)
    @language = Language.find(language_id)
    # Создаем Set для быстрого поиска нужных полей
    @fields = Set.new(fields)
    @pretty = pretty
  end

  def call
    data = {
      meta: build_meta,
      lexemes: serialize_lexemes,
      roots: serialize_roots,
      affixes: serialize_affixes
    }

    if @pretty
      JSON.pretty_generate(data)
    else
      data.to_json
    end
  end

  private

  # построение структуры

  def build_meta
    {
      language: {
        name: @language.name,
        code: @language.code
      },
      exported_at: Time.current.iso8601,
      schema_version: "1.0"
    }
  end

  def serialize_lexemes
    # Жадная загрузка всех связанных данных для избежания N+1
    lexemes = @language.lexemes.preload(words: [:parts_of_speech, :etymology])

    lexemes.map do |lexeme|
      data = {}
      data[:spelling] = lexeme.spelling if field_selected?("spelling")
      data[:words] = lexeme.words.map { |word| serialize_word(word) }
      data
    end
  end

  def serialize_word(word)
    data = {}
    data[:definition] = word.definition if field_selected?("words.definition")
    data[:transcription] = word.transcription if field_selected?("words.transcription")
    data[:comment] = word.comment if field_selected?("words.comment")

    if field_selected?("words.parts_of_speech")
      data[:parts_of_speech] = word.parts_of_speech.map(&:code)
    end

    if field_selected?("words.etymology") && word.etymology.present?
      data[:etymology] = {
        explanation: word.etymology.explanation,
        comment: word.etymology.comment
      }
    end
    data
  end

  def serialize_roots
    @language.roots.preload(:etymology).map do |root|
      data = {}
      data[:text] = root.text if field_selected?("text", "Root")
      data[:meaning] = root.meaning if field_selected?("meaning", "Root")
      if field_selected?("etymology", "Root") && root.etymology.present?
        data[:etymology] = { explanation: root.etymology.explanation }
      end
      data
    end
  end

  def serialize_affixes
    @language.affixes.preload(:etymology).map do |affix|
      data = {}
      data[:text] = affix.text if field_selected?("text", "Affix")
      data[:meaning] = affix.meaning if field_selected?("meaning", "Affix")
      data[:affix_type] = affix.affix_type if field_selected?("affix_type", "Affix")
      if field_selected?("etymology", "Affix") && affix.etymology.present?
        data[:etymology] = { explanation: affix.etymology.explanation }
      end
      data
    end
  end

  # Вспомогательный метод для проверки полей
  def field_selected?(field_name, model_prefix = nil)
    # Для вложенных полей (word), `field_name` будет "words.definition"
    # Для простых (root), мы сами передаем `model_prefix`
    key = model_prefix ? field_name.downcase : field_name
    @fields.include?(key)
  end
end
