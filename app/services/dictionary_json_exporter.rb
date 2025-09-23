# frozen_string_literal: true

class DictionaryJsonExporter
  def self.call(...)
    new(...).call
  end

  def initialize(language_id:, fields: [], pretty: true, part_of_speech_ids: [])
    @language = Language.find(language_id)
    @fields = Set.new(fields)
    @pretty = pretty
    @part_of_speech_ids = part_of_speech_ids
  end

  def call
    data = {
      meta: build_meta,
      lexemes: serialize_lexemes,
      roots: serialize_roots,
      affixes: serialize_affixes
    }

    @pretty ? JSON.pretty_generate(data) : data.to_json
  end

  private

  def build_meta
    {
      language: { name: @language.name, code: @language.code },
      exported_at: Time.current.iso8601,
      schema_version: "1.0"
    }
  end

  def serialize_lexemes
    base_scope = @language.lexemes.preload(words: [:parts_of_speech, :etymology])

    scope = if @part_of_speech_ids.present?
              base_scope.joins(words: :parts_of_speech)
                        .where(parts_of_speech: { id: @part_of_speech_ids }).distinct
            else
              base_scope
            end

    scope.map do |lexeme|
      data = {}
      data[:spelling] = lexeme.spelling if field_selected?("lexeme.spelling")
      data[:words] = lexeme.words.map { |word| serialize_word(word) }
      data
    end
  end

  def serialize_word(word)
    data = {}
    data[:definition] = word.definition if field_selected?("word.definition")
    data[:transcription] = word.transcription if field_selected?("word.transcription")
    data[:comment] = word.comment if field_selected?("word.comment")

    if field_selected?("word.parts_of_speech")
      data[:parts_of_speech] = word.parts_of_speech.map(&:code)
    end

    if field_selected?("word.etymology") && word.etymology.present?
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
      data[:text] = root.text if field_selected?("root.text")
      data[:meaning] = root.meaning if field_selected?("root.meaning")
      if field_selected?("root.etymology") && root.etymology.present?
        data[:etymology] = { explanation: root.etymology.explanation }
      end
      data
    end
  end

  def serialize_affixes
    @language.affixes.preload(:etymology).map do |affix|
      data = {}
      data[:text] = affix.text if field_selected?("affix.text")
      data[:meaning] = affix.meaning if field_selected?("affix.meaning")
      data[:affix_type] = affix.affix_type if field_selected?("affix.affix_type")
      if field_selected?("affix.etymology") && affix.etymology.present?
        data[:etymology] = { explanation: affix.etymology.explanation }
      end
      data
    end
  end

  def field_selected?(field_key)
    @fields.include?(field_key)
  end
end
