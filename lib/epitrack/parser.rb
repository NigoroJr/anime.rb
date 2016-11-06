require 'epitrack/series'
require 'epitrack/episode'

require 'levenshtein'

class Epitrack
  # A module that parses the filenames and determines a template for that
  # series.
  module Parser
    PLACEHOLDER = '{}'.freeze

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

      (fn1, fn2) = similar_two(filenames)

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
        end
      end

      # Assume that the correct template was obtained and find the first and
      # last episode numbers
      sorted_episode_numbers = filenames \
        .select { |fn| fn.size == fn1.size } \
        # Ignore everything up to the placeholder
        .map { |fn| fn[placeholder_idx..-1] } \
        # Filenames should now begin with episode numbers
        .map { |fn| fn.match(/^\d+/) && Regexp.last_match(0) } \
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
        if dist < best_so_far && dist >= best_dist
          best_pair = [a, b]
          best_so_far = dist
        end
      end

      best_pair
    end
  end
end
