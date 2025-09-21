# frozen_string_literal: true

class Pub::GrammarRulesController < Pub::BaseController
  def show
    @grammar_rule = GrammarRule.published.find_by!(slug: params[:id])
  end
end
