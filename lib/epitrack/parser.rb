require 'epitrack/series'
require 'epitrack/episode'

require 'levenshtein'

class Epitrack
  # A module that parses the filenames and determines a template for that
  # series.
  module Parser
    PLACEHOLDER = '{}'.freeze
    PLACEHOLDER_GLOB = '{*}'.freeze
    # Parse file names as if these words (plus spaces around them) don't exist
    IGNORE_WORDS = %w(RAW END).freeze

    module_function

    # Parses the filename to find where the episode number is.
    # At least one filename must be given to this method. The more filenames
    # there are, the more accurate the template becomes. If more than two
    # filenames are given, the two that are most similar to each other in
    # terms of Levenshtein distance are used.
    #
    # @param filenames [Array<String>, String] the filename to parse.
    #
    # @return [String, Integer, Integer] template, first, last ep numbers.
    def parse(filenames)
      filenames = [filenames] unless filenames.is_a?(Enumerable)

      return guess_template(filenames.first) if filenames.length < 2

      # Sometimes the name of the last episode is '42 END something.mp4'
      # Change this to '42 something.mp4' (remove the " END" part)
      pat = /(\d+)\s*\b(?:#{IGNORE_WORDS.join('|')})\b/
      has_end_in_template = filenames.any? { |fn| fn =~ pat }
      filenames.map! { |fn| fn.sub(pat, '\1') } if has_end_in_template

      (fn1, fn2) = similar_two(filenames, 2)

      if fn1.length != fn2.length
        raise "Filenames have different lengths (#{fn1.length}, #{fn2.length})"
      end

      template = ''
      placeholder_idx = nil
      flag = true
      # fn1 and fn2 have same lengths
      0.upto(fn1.length - 1).each do |i|
        if fn1[i] == fn2[i]
          template << fn1[i]
        elsif flag
          flag = false
          template << PLACEHOLDER
          placeholder_idx = i

          # Make the template foobar{}{*}baz.mp4 where {*} is for the 'END'
          template << PLACEHOLDER_GLOB if has_end_in_template
        end
      end

      # Assume that the correct template was obtained and find the first and
      # last episode numbers
      sorted_episode_numbers = filenames \
        .select { |fn| fn.size == fn1.size } \
        # Ignore everything up to the placeholder
        .map { |fn| fn[placeholder_idx..-1] } \
        # Filenames should now begin with episode numbers (or nil)
        .map { |fn| fn.match(/^\d+/) && Regexp.last_match(0) } \
        # Remove nil elements
        .compact \
        .map(&:to_i) \
        .sort

      first_ep = sorted_episode_numbers.first
      last_ep = sorted_episode_numbers.last

      [template, first_ep, last_ep]
    end

    # Uses regular expression to guess the template from the filename.
    # The accuracy of the resulting template is lower compared to when using
    # more than one filename.
    #
    # @param filename [String] the filename to be used.
    #
    # @return [String, nil] the guessed template. nil if none could be
    #   guessed.
    def guess_template(filename)
      return unless filename =~ /(?<=[^\dS]|^)(\d\d)(?=[^\d]|$)/

      m = Regexp.last_match
      ep_num = m[0].to_i
      template = m.pre_match + PLACEHOLDER + m.post_match
      [template, ep_num, ep_num]
    end

    # Finds the first and last episode numbers from a template.
    #
    # @param template [String] template that contains a "{}", where the
    #   episode number is substituted into.
    #
    # @return [Integer, Integer] the first and last episode numbers.
    def find_first_last(template)
      unless template.include?(PLACEHOLDER)
        raise "Template must contain a #{PLACEHOLDER}"
      end

      pattern = Shellwords.escape(template) \
        .sub(Shellwords.escape(Epitrack::Parser::PLACEHOLDER), '*') \
        .sub(Shellwords.escape(Epitrack::Parser::PLACEHOLDER_GLOB), '*')

      sorted_episode_numbers = Dir[pattern] \
        # Remove everything up to the placeholder
        .map { |f| f[template.index(Epitrack::Parser::PLACEHOLDER)..-1] } \
        # Now numbers should be at the front
        .map { |f| f.match(/^(\d+)/) && Regexp.last_match(1) } \
        .compact \
        .map(&:to_i) \
        .sort

      [sorted_episode_numbers.first, sorted_episode_numbers.last]
    end

    private

    module_function

    # Finds two strings that are similar to each other.
    # The best levenshtein distance by default is 2, since the episode number
    # is assumed to be two digits.
    #
    # @param str [Array<String>] the strings to be examined.
    #
    # @param best_dist [Integer] the distance to prefer the most.
    #
    # @return [Pair<String>] the two closest-matching strings.
    def similar_two(str, best_dist = 2)
      best_pair = str.first(2)
      # Arbitrarily large distance
      best_so_far = str.map(&:length).max * 42

      str.combination(2).each do |a, b|
        next if a.length != b.length

        dist = Levenshtein.distance(a, b)

        return [a, b] if dist == best_dist

        if dist < best_so_far
          best_pair = [a, b]
          best_so_far = dist
        end
      end

      best_pair
    end
  end
end
