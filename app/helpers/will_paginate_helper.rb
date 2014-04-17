module WillPaginateHelper

  class LinkRenderer < WillPaginate::ActionView::LinkRenderer

    def to_html
      if @options.has_key?(:reverse) && @options[:reverse] == true
        my_pagination =  pagination.reverse
      else
        my_pagination = pagination
      end

      html = my_pagination.map do |item|
        item.is_a?(Fixnum) ?
          page_number(item) :
          send(item)
      end.join(@options[:link_separator])

      @options[:container] ? html_container(html) : html
    end


    def html_container(html)
      tag(:div, "<ul>#{html}</ul>", container_attributes)
    end


    def page_number(page)
      unless page == current_page
        tag(:li, link(page, page, :rel => rel_value(page)))
      else
        tag(:li, link(page, '#'), :class => 'active')
      end
    end


    def previous_or_next_page(page, text, classname)
      if page
        tag(:li, link(text, page, :class => classname))
      else
        tag(:li, "<span>#{text}</span>", :class => classname + ' disabled')
      end
    end


    def link(text, target, attributes = {})
      if @options.has_key?(:remote) && @options[:remote] == true
        attributes['data-remote'] = true
      end
      super
    end


    def gap
      text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
      %(<li><span class="gap">#{text}</span></li>)
    end

  end
end
