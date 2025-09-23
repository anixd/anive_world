# frozen_string_literal: true

module MarkdownHelper
  def render_markdown(text)
    return "" if text.blank?

    context = controller.class.module_parent.name == "Pub" ? :pub : :forge

    processed_text = WikilinkPreprocessor.call(text, context: context)

    markdown_renderer.render(processed_text).html_safe
  end

  private

  def markdown_renderer
    @markdown_renderer ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(link_attributes: { target: '_blank', rel: 'noopener' }),
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      underline: true,
      highlight: true,
      quote: true,
    )
  end
end
