# Override module that will strip all whitespace from the HTML in production
module Haml
  class Parser
    def parse_tag_with_nuked_whitespace(line)
      result = parse_tag_without_nuked_whitespace line
      unless result.size == 9 && [false, true].include?(result[4]) && [false, true].include?(result[5])
        raise "Unexpected parse_tag output: #{result.inspect}"
      end
      result[4] = true # nuke_outer_whitespace
      result[5] = true # nuke_inner_whitespace
      result
    end
    alias_method_chain :parse_tag, :nuked_whitespace if ::Rails.application.config.compact_haml
  end
end
