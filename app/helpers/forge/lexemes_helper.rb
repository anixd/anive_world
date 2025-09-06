module Forge::LexemesHelper
  def options_for_part_of_speech(all_options, lexeme)
    if lexeme.language_id.present?
      all_options.where(language_id: lexeme.language_id)
    else
      []
    end
  end
end
