# frozen_string_literal: true

class Forge::RootsController < Forge::BaseController
  before_action :set_language_from_id, except: [:index]
  before_action :set_root, only: %i[edit update destroy]

  def index
    @languages = Language.order(:name)
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @current_language = @languages.find { |l| l.code == target_code } || Language.order(:name).first

    scope = if @current_language
              @current_language.roots.includes(:author).order(:text)
            else
              Root.none
            end

    @pagy, @roots = pagy(policy_scope(scope))
  end

  def new
    @root = @language.roots.build
    @root.build_etymology
    authorize @root
  end

  def create
    attrs = root_params.to_h
    publish_flag = attrs.delete(:publish)

    @root = @language.roots.build(attrs)
    @root.author = current_user
    authorize @root

    if @root.etymology.present?
      @root.etymology.author = current_user
    end

    @root.published_at = Time.current if publish_flag == '1'

    if @root.save
      redirect_to forge_language_roots_path(@language, lang: @language.code), notice: "Root was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @root
    @root.build_etymology if @root.etymology.nil?
  end

  def update
    authorize @root

    attrs = root_params.to_h
    publish_flag = attrs.delete(:publish)

    @root.assign_attributes(attrs)
    @root.published_at = (publish_flag == '1') ? Time.current : nil

    if @root.etymology.present? && @root.etymology.new_record?
      @root.etymology.author = current_user
    end

    if @root.save
      redirect_to forge_language_roots_path(@language, lang: @language.code), notice: "Root was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @root
    @root.discard
    redirect_to forge_language_roots_path(@language, lang: @language.code), notice: "Root was archived."
  end

  private

  def set_language_from_id
    @language = Language.find(params[:language_id])
  end

  def set_root
    @root = @language.roots.find(params[:id])
  end

  def handle_publication(record)
    if params.dig(:lexeme, :publish) == '1'
      record.published_at = Time.current
    else
      record.published_at = nil
    end
  end

  def root_params
    params.require(:root).permit(
      :text, :meaning, :publish,
      etymology_attributes: [:id, :explanation, :comment]
    )
  end
end