module MarkdownHelper
  # Метод для рендеринга простого Markdown
  def render_markdown(text)
    # Возвращаем пустую строку, если на входе nil, чтобы избежать ошибок
    return '' if text.blank?

    # Вызываем рендерер и помечаем результат как безопасный HTML
    markdown_renderer.render(text).html_safe
  end

  private

  # Инициализация Redcarpet с твоими настройками
  def markdown_renderer
    # Используем memoization, чтобы не создавать новый объект при каждом вызове
    @markdown_renderer ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        hard_wrap: true,
        link_attributes: { target: '_blank', rel: 'noopener' }
      ),
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      underline: true,
      highlight: true,
      quote: true,
      footnotes: true,
      no_intra_emphasis: true,
      lax_spacing: true
    )
  end
end
