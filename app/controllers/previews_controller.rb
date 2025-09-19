# frozen_string_literal: true

class PreviewsController < ApplicationController
  include Pundit::Authorization
  include MarkdownHelper

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def show
    record = WikilinkResolver.resolve(params[:type], nil, params[:slug])

    if record.nil?
      render json: { error: "Not found" }, status: :not_found
      return
    end

    authorize record, :show_preview?
    render json: build_preview_for(record)
  end

  private

  def build_preview_for(record)
    case record
    when Lexeme
      build_lexeme_preview(record)
    when Article, HistoryEntry, Character, Location, GrammarRule, PhonologyArticle
      build_content_entry_preview(record)
    else
      { title: "Unsupported Type", summary: "Preview not available." }
    end
  end

  def build_lexeme_preview(lexeme)
    word = lexeme.words.first
    summary_html = helpers.render_markdown(word&.definition.to_s)
    plain_summary = helpers.strip_tags(summary_html)
    summary = plain_summary.truncate(200)

    {
      title: lexeme.spelling,
      type: "word",
      transcription: word&.transcription,
      summary: summary
    }
  end

  def build_content_entry_preview(entry)
    summary_source = entry.try(:extract).presence || entry.try(:annotation).presence || entry.body
    full_html = helpers.render_markdown(summary_source.to_s)
    summary = helpers.truncate_html(full_html, length: 250, omission: "...")

    image_url = nil
    if entry.respond_to?(:images) && entry.images.attached?
      image_url = url_for(entry.images.first.variant(:preview)) rescue nil
    end

    {
      title: entry.title,
      type: entry.class.name.underscore.dasherize,
      summary: summary,
      image_url: image_url
    }
  end

  def user_not_authorized
    render json: { error: "Forbidden" }, status: :forbidden
  end
end
