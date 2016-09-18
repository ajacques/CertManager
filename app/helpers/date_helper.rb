module DateHelper
  def inline_ago_string(timestamp, format: :long)
    tz_adjusted = localize timestamp.in_time_zone(current_user.time_zone), format: format
    ago = time_ago_in_words(timestamp)
    translate 'time.composed.inline_string', time: tz_adjusted, ago: ago
  end
end
