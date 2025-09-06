module PaginationHelper
  def pagy_tailwind_nav(pagy)
    return "" if pagy.pages <= 1

    # Контейнер
    nav_html = '<nav class="isolate inline-flex -space-x-px rounded-lg shadow-sm">'

    # Кнопка "Назад"
    prev_link = pagy.prev ? link_to("← Previous", pagy_url_for(pagy, pagy.prev), class: "relative inline-flex items-center rounded-l-md px-3 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20") : "<span class=\"relative inline-flex items-center rounded-l-md px-3 py-2 text-gray-300 ring-1 ring-inset ring-gray-300 cursor-not-allowed\">← Previous</span>"
    nav_html << prev_link

    # Страницы
    pagy.series.each do |item|
      case item
      when Integer
        nav_html << link_to(item, pagy_url_for(pagy, item), class: "relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20")
      when String
        nav_html << "<span class=\"relative z-10 inline-flex items-center bg-blue-600 px-4 py-2 text-sm font-semibold text-white focus:z-20\">#{item}</span>"
      when :gap
        nav_html << '<span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300">...</span>'
      end
    end

    # Кнопка "Вперёд"
    next_link = pagy.next ? link_to("Next →", pagy_url_for(pagy, pagy.next), class: "relative inline-flex items-center rounded-r-md px-3 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20") : "<span class=\"relative inline-flex items-center rounded-r-md px-3 py-2 text-gray-300 ring-1 ring-inset ring-gray-300 cursor-not-allowed\">Next →</span>"
    nav_html << next_link

    nav_html << '</nav>'
    nav_html.html_safe
  end
end
