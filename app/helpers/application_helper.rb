# frozen_string_literal: true

module ApplicationHelper
  def app_version
    ENV['APP_VERSION'] || '1.0.0'
  end

  def app_build_date
    ENV['BUILD_DATE'] || Time.current.to_date.to_s
  end

  def render_chat_markdown(text)
    return '' if text.blank?

    lines = text.to_s.lines
    html = []
    list_items = []

    flush_list = proc do
      html << "<ul>#{list_items.join}</ul>" if list_items.any?
      list_items.clear
    end

    lines.each do |line|
      line = line.chomp

      if (heading = line.match(/^###\s+(.+)$/))
        flush_list.call
        html << "<h3>#{render_chat_inline(heading[1])}</h3>"
      elsif (heading = line.match(/^##\s+(.+)$/))
        flush_list.call
        html << "<h2>#{render_chat_inline(heading[1])}</h2>"
      elsif (heading = line.match(/^#\s+(.+)$/))
        flush_list.call
        html << "<h1>#{render_chat_inline(heading[1])}</h1>"
      elsif (item = line.match(/^[-*]\s+(.+)$/))
        list_items << "<li>#{render_chat_inline(item[1])}</li>"
      elsif line.blank?
        flush_list.call
      else
        flush_list.call
        html << "<p>#{render_chat_inline(line)}</p>"
      end
    end

    flush_list.call
    sanitize(html.join, tags: %w[h1 h2 h3 p ul ol li strong em br], attributes: [])
  end

  private

  def render_chat_inline(text)
    escaped = ERB::Util.html_escape(text.to_s)

    escaped
      .gsub(/\*\*(.+?)\*\*/) { "<strong>#{$1}</strong>" }
      .gsub(/__(.+?)__/) { "<strong>#{$1}</strong>" }
      .gsub(/\*(.+?)\*/) { "<em>#{$1}</em>" }
      .gsub(/_(.+?)_/) { "<em>#{$1}</em>" }
  end
end
