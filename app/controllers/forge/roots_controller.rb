# frozen_string_literal: true

class Forge::RootsController < Forge::BaseController
  before_action :set_language_from_id, except: [:index]
  before_action :set_root, only: %i[show edit update destroy]

  def index
    @languages = Language.order(:name)
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @current_language = @languages.find { |l| l.code == target_code } || Language.order(:name).first

    scope = if @current_language
              @current_language.roots.kept.includes(:author, :etymology).order(:text)
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

  def show
    authorize @root
  end

  def create
    @root = @language.roots.build(root_params.except(:publish))
    @root.author = current_user
    authorize @root

    if @root.etymology.present?
      @root.etymology.author = current_user
    end

    if request.format.json?
      @root.published_at = Time.current
    else
      @root.publish = root_params[:publish]
    end

    respond_to do |format|
      if @root.save
        format.html { redirect_to forge_language_roots_path(@language, lang: @language.code), notice: "Root was created." }
        format.json { render json: { id: @root.id, text: @root.text, type: 'Root' }, status: :created }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { errors: @root.errors.full_messages }, status: :unprocessable_content }
      end
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
    @root.published_at = (publish_flag == "1") ? Time.current : nil

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

    # redirect_to forge_language_roots_path(@language, lang: @language.code), notice: "Root was archived."
    respond_to do |format|
      format.html { redirect_to forge_language_roots_path(@language, lang: @language.code), notice: "Root was archived." }
      format.turbo_stream
    end
  end

  private

  def set_language_from_id
    @language = Language.find(params[:language_id])
  end

  def set_root
    @root = @language.roots.find_by!(slug: params[:id])
  end

  def handle_publication(record)
    if params.dig(:lexeme, :publish) == "1"
      record.published_at = Time.current
    else
      record.published_at = nil
    end
  end

  def root_params
    params.require(:root).permit(
      :text, :meaning, :publish, :transcription,
      etymology_attributes: [:id, :explanation, :comment]
    )
  end
end