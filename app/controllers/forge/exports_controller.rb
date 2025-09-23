# frozen_string_literal: true

class Forge::ExportsController < Forge::BaseController
  # Поля, доступные для экспорта, сгруппированные по моделям.
  # Ключи - для отображения пользователю, значения - для использования в коде.
  AVAILABLE_FIELDS = {
    "Lexeme & Word" => {
      "Spelling" => "lexeme.spelling",
      "Definition" => "word.definition",
      "Transcription" => "word.transcription",
      "Comment" => "word.comment",
      "Parts of Speech" => "word.parts_of_speech",
      "Etymology" => "word.etymology"
    },
    "Root" => {
      "Text" => "root.text",
      "Meaning" => "root.meaning",
      "Etymology" => "root.etymology"
    },
    "Affix" => {
      "Text" => "affix.text",
      "Meaning" => "affix.meaning",
      "Affix Type" => "affix.affix_type",
      "Etymology" => "affix.etymology"
    }
  }.freeze

  def show
    authorize :export, :show?
    @languages = Language.order(:name)
    @field_groups = AVAILABLE_FIELDS
  end

  def dictionary
    authorize :export, :dictionary?

    pretty_print = params[:pretty_print] == "1"
    part_of_speech_ids = params[:part_of_speech_ids]&.reject(&:blank?)

    json_data = DictionaryJsonExporter.call(
      language_id: params[:language_id],
      fields: params[:fields] || [],
      part_of_speech_ids: part_of_speech_ids || [],
      pretty: pretty_print
    )

    filename = "#{Time.current.strftime('%Y-%m-%d')}_dictionary_#{Language.find(params[:language_id]).code}.json"

    send_data json_data, filename: filename, type: "application/json"
  end

  def parts_of_speech
    language = Language.find_by(id: params[:language_id])
    @parts_of_speech = language ? language.parts_of_speech.order(:name) : []

    respond_to do |format|
      format.turbo_stream
    end
  end
end
