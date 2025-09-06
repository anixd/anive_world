module WillPaginate
  module ActionView
    class TailwindRenderer < LinkRenderer
      def html_container(html)
        tag(:nav, tag(:ul, html, class: "flex items-center -space-x-px h-8 text-sm"), class: "pagination")
      end

      def page_number(page)
        link_classes = "flex items-center justify-center px-3 h-8 leading-tight border"

        if page == current_page
          tag(:li, tag(:span, page, class: "#{link_classes} text-blue-600 bg-blue-50 border-blue-300"), class: "z-10")
        else
          tag(:li, link(page, page, rel: rel_value(page), class: "#{link_classes} text-gray-500 bg-white border-gray-300 hover:bg-gray-100 hover:text-gray-700"))
        end
      end

      def previous_or_next_page(page, text, classname)
        link_classes = "flex items-center justify-center px-3 h-8 ml-0 leading-tight border"

        if page
          if classname == "previous_page"
            link_classes << " rounded-l-lg"
          elsif classname == "next_page"
            link_classes << " rounded-r-lg"
          end
          tag(:li, link(text, page, class: "#{link_classes} text-gray-500 bg-white border-gray-300 hover:bg-gray-100 hover:text-gray-700"))
        else
          if classname == "previous_page"
            link_classes << " rounded-l-lg"
          elsif classname == "next_page"
            link_classes << " rounded-r-lg"
          end
          tag(:li, tag(:span, text, class: "#{link_classes} text-gray-400 bg-gray-50 cursor-not-allowed"), class: classname + ' disabled')
        end
      end

      def gap
        tag(:li, tag(:span, '&hellip;'.html_safe, class: "flex items-center justify-center px-3 h-8 leading-tight text-gray-500 bg-white border border-gray-300"))
      end
    end
  end
end
