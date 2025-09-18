# frozen_string_literal: true

class Forge::GrammarRulesController < Forge::BaseController
  before_action :set_grammar_rule, only: %i[show edit update destroy]
  before_action :set_form_options, only: %i[new edit create update]

  def index
    @languages = Language.order(:name)
    target_code = params.fetch(:lang, Language::DEFAULT_CODE)
    @current_language = @languages.find { |l| l.code == target_code } || @languages.first

    scope = if @current_language
              policy_scope(GrammarRule).includes(:tags).where(language_id: @current_language.id).order(title: :asc)
            else
              GrammarRule.none
            end
    @pagy, @grammar_rules = pagy(scope)
  end

  def show
    authorize @grammar_rule
  end

  def new
    @grammar_rule = GrammarRule.new
    authorize @grammar_rule
  end

  def create
    @grammar_rule = GrammarRule.new(grammar_rule_params)
    @grammar_rule.author = current_user
    authorize @grammar_rule

    if @grammar_rule.save
      redirect_to forge_grammar_rule_path(@grammar_rule), notice: "Grammar rule was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @grammar_rule
  end

  def update
    authorize @grammar_rule
    if @grammar_rule.update(grammar_rule_params)
      redirect_to forge_grammar_rule_path(@grammar_rule), notice: "Grammar rule was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @grammar_rule
    @grammar_rule.discard
    redirect_to forge_grammar_rules_path, notice: "Grammar rule was archived."
  end

  private

  def set_grammar_rule
    @grammar_rule = GrammarRule.includes(:tags).find_by!(slug: params[:id])
  end

  def set_form_options
    @languages = Language.order(:name)
  end

  def grammar_rule_params
    params.require(:grammar_rule).permit(:title, :body, :language_id, :rule_code, :tags_string)
  end
end
