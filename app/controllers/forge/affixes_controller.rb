# frozen_string_literal: true

class Forge::AffixesController < Forge::BaseController
  before_action :set_language_from_id, except: [:index]
  before_action :set_affix, only: %i[show edit update destroy]
  before_action :set_form_options, only: %i[new create edit update]

  def index
  @languages = Language.order(:name)
  target_code = params.fetch(:lang, Language::DEFAULT_CODE)
  @current_language = @languages.find { |l| l.code == target_code } || Language.order(:name).first

  scope = if @current_language
            @affix_categories = @current_language.affix_categories.order(:name)
            @current_language.affixes.includes(:author, :affix_category, :etymology).order(:text)
          else
            Affix.none
          end

  scope = scope.where(affix_category_id: params[:category_id]) if params[:category_id].present?

  @pagy, @affixes = pagy(policy_scope(scope))
end

  def new
    @affix = @language.affixes.build
    @affix.build_etymology
    authorize @affix
  end

  def show
    authorize @affix
  end

  def create
    attrs = affix_params.to_h
    publish_flag = attrs.delete(:publish)

    @affix = @language.affixes.build(attrs)
    @affix.author = current_user
    authorize @affix

    if @affix.etymology.present?
      @affix.etymology.author = current_user
    end

    @affix.published_at = Time.current if publish_flag == '1'

    if @affix.save
      redirect_to forge_language_affixes_path(@language, lang: @language.code), notice: "Affix was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @affix
    @affix.build_etymology if @affix.etymology.nil?
  end

  def update
    authorize @affix

    attrs = affix_params.to_h
    publish_flag = attrs.delete(:publish)

    @affix.assign_attributes(attrs)
    @affix.published_at = (publish_flag == '1') ? Time.current : nil

    if @affix.etymology.present? && @affix.etymology.new_record?
      @affix.etymology.author = current_user
    end

    if @affix.save
      redirect_to forge_language_affixes_path(@language, lang: @language.code), notice: "Affix was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @affix
    @affix.discard
    redirect_to forge_language_affixes_path(@language, lang: @language.code), notice: "Affix was archived."
  end

  private

  def set_form_options
    @affix_categories = @language.affix_categories.order(:name)
  end

  def set_language_from_id
    @language = Language.find(params[:language_id])
  end

  def set_affix
    @affix = @language.affixes.find_by!(slug: params[:id])
  end

  def handle_publication(record)
    if params.dig(:lexeme, :publish) == '1'
      record.published_at = Time.current
    else
      record.published_at = nil
    end
  end

  def affix_params
    params.require(:affix).permit(
      :text, :affix_type, :meaning, :publish, :affix_category_id, :destroy, :transcription,
      etymology_attributes: [:id, :explanation, :comment]
    )
  end
end
