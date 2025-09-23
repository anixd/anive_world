# frozen_string_literal: true

class Forge::ExportsController < Forge::BaseController
  # Поля, доступные для экспорта, сгруппированные по моделям.
  # Ключи - для отображения пользователю, значения - для использования в коде.
  AVAILABLE_FIELDS = {
    "Lexeme & Word" => {
      "Spelling (Lexeme)" => "spelling",
      "Definition" => "words.definition",
      "Transcription" => "words.transcription",
      "Comment" => "words.comment",
      "Parts of Speech" => "words.parts_of_speech",
      "Etymology" => "words.etymology"
    },
    "Root" => {
      "Text" => "text",
      "Meaning" => "meaning",
      "Etymology" => "etymology"
    },
    "Affix" => {
      "Text" => "text",
      "Meaning" => "meaning",
      "Affix Type" => "affix_type",
      "Etymology" => "etymology"
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

    json_data = DictionaryJsonExporter.call(
      language_id: params[:language_id],
      fields: params[:fields] || [],
      pretty: pretty_print
    )

    filename = "#{Time.current.strftime('%Y-%m-%d')}_dictionary_#{Language.find(params[:language_id]).code}.json"

    send_data json_data, filename: filename, type: "application/json"
  end
end
