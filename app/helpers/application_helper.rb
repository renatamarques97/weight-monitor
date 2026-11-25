# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def app_version
    ENV['APP_VERSION'] || '1.0.0'
  end

  def app_build_date
    ENV['BUILD_DATE'] || Time.current.to_date.to_s
  end

  def workout_duration(duration)
    number_with_precision(duration, precision: 2, strip_insignificant_zeros: true)
  end

  def render_chat_markdown(text)
    return '' if text.blank?

    html = []
    list_items = []
    text.to_s.lines.each { |line| append_chat_markdown_line(line.chomp, html, list_items) }
    flush_chat_list(html, list_items)

    sanitize_chat_markdown(html.join)
  end

  def weight_trend_direction(trend, initial_weight, target_weight)
    return 'neutral' if trend.nil? || trend.zero? || initial_weight.nil? || target_weight.nil?

    goal_direction = target_weight <=> initial_weight
    return 'neutral' if goal_direction.zero?

    trend_direction = trend <=> 0

    goal_direction == trend_direction ? 'positive' : 'negative'
  end

  def weight_trend_color(trend, initial_weight, target_weight)
    {
      'positive' => 'text-emerald-600',
      'negative' => 'text-amber-600',
      'neutral' => 'fit-text-secondary'
    }.fetch(weight_trend_direction(trend, initial_weight, target_weight))
  end

  def training_duration_hours(total_minutes)
    total_minutes = total_minutes.round
    hours = total_minutes / 60
    minutes = total_minutes % 60

    t('workout.training_duration', hours: hours, minutes: minutes)
  end

  private

  def append_chat_markdown_line(line, html, list_items)
    return append_chat_heading(line, html, list_items) if chat_heading_match(line)
    return append_chat_list_item(line, list_items) if chat_list_item_match(line)

    flush_chat_list(html, list_items)
    html << "<p>#{render_chat_inline(line)}</p>" if line.present?
  end

  def append_chat_heading(line, html, list_items)
    flush_chat_list(html, list_items)
    match = chat_heading_match(line)
    level = match[1].length
    html << "<h#{level}>#{render_chat_inline(match[2])}</h#{level}>"
  end

  def append_chat_list_item(line, list_items)
    item = chat_list_item_match(line)
    list_items << "<li>#{render_chat_inline(item[1])}</li>"
  end

  def chat_heading_match(line)
    match = line.match(/\A(#+)\s+(.+)\z/)
    match if match && match[1].length <= 3
  end

  def chat_list_item_match(line)
    line.match(/\A[-*]\s+(.+)\z/)
  end

  def flush_chat_list(html, list_items)
    html << "<ul>#{list_items.join}</ul>" if list_items.any?
    list_items.clear
  end

  def sanitize_chat_markdown(html)
    sanitize(html, tags: %w[h1 h2 h3 p ul ol li strong em br], attributes: [])
  end

  def render_chat_inline(text)
    escaped = ERB::Util.html_escape(text.to_s)

    escaped
      .gsub(/\*\*(.+?)\*\*/) { "<strong>#{::Regexp.last_match(1)}</strong>" }
      .gsub(/__(.+?)__/) { "<strong>#{::Regexp.last_match(1)}</strong>" }
      .gsub(/\*(.+?)\*/) { "<em>#{::Regexp.last_match(1)}</em>" }
      .gsub(/_(.+?)_/) { "<em>#{::Regexp.last_match(1)}</em>" }
  end
end
