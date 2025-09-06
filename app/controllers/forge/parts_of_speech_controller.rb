class Forge::PartsOfSpeechController < Forge::BaseController
  def index
    @language = Language.find(params[:language_id])
    @parts_of_speech = @language.parts_of_speech.order(:name)

    # Контроллер будет автоматически искать вьюху index.turbo_stream.erb
  end
end
