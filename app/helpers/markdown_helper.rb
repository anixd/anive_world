module MarkdownHelper
  def render_markdown(text)
    return '' if text.blank?

    markdown_renderer.render(text).html_safe
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
