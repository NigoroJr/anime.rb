require 'epitrack/episode'

require 'date'

class Epitrack
  # Represents a series.
  class Series
    attr_accessor :name
    attr_accessor :template
    # The episode to start watching next
    attr_accessor :current_ep
    attr_accessor :episodes

    # Creates a new Epitrack::Series instance.
    # Properties can be given such as the start date of watching, filename
    # template, and current episode number.
    #
    # @param name [String] the name of this series.
    #
    # @param history [Array<[Integer, DateTime, DateTime]>] history of episodes
    #
    # @param properties [Hash{Symbol => Object}] properties of this series.
    def initialize(name, history, properties = {})
      @name = name
      @template = properties[:template]
      @current_ep = properties[:current_ep].to_i

      @episodes = []
      history.each do |episode|
        ep_num, first_watched, last_watched = episode
        ep = Epitrack::Episode.new(ep_num, first_watched, last_watched)
        @episodes.push(ep)
      end
    end

    # Shorthand for srs.episodes[idx]
    #
    # @param idx [Integer] the index number
    #
    # @return [Episode] the corresponding instance
    def [](idx)
      @episodes[idx]
    end

    # Returns the episode for the given number.
    #
    # @param ep_num [Integer, String] the episode number.
    #
    # @return [Episode] the episode.
    def ep(ep_num)
      idx = @episodes.map(&:number).index(ep_num.to_i)
      return nil if idx.nil?
      @episodes[idx]
    end

    # Returns an Enumerator for the episodes.
    # If block is given, the block is applied to each episode. Otherwise, an
    # Enumerator for each episode is returned.
    #
    # @return [Enumerator] Enumerator of the episodes.
    def each(&block)
      @episodes.each(&block)
    end

    # Returns the total number of episodes in this series.
    #
    # @return [Integer] the total number of episodes in this series.
    def size
      @episodes.size
    end

    # Returns the final episode number of this series
    #
    # @return [Integer] the final episode number.
    def final_ep
      @episodes.last.number
    end

    # Returns when this series was started
    #
    # @return [DateTime] the date and time that this series was started at
    def started_at
      @episodes.first.first_watched
    end

    # Returns when this series was finished
    #
    # @return [DateTime] the date and time that this series was finished at.
    def finished_at
      @episodes.last.first_watched
    end

    # Returns whether this series was finished
    #
    # @return [Boolean] whether the last episode has been watched.
    def finished?
      @episodes.last.watched?
    end

    # Returns the path to the next episode
    #
    # @param [Hash] opts the options when constructing the file path
    # @option opts [Integer] :digits (2) digits in the episode number
    # @option opts [Boolean] :expand_glob (true) expand {*} (glob placeholder)
    #
    # @return [String] the path to the next episode
    def current_episode_path(opts = {})
      opts[:digits] ||= 2
      opts[:expand_glob] ||= true

      str = format '%0*i', opts[:digits], @current_ep
      path = @template.sub(Epitrack::Parser::PLACEHOLDER, str)

      if opts[:expand_glob]
        path = Shellwords.escape(path)
        # PLACEHOLDER_GLOB in path is also escaped
        escaped_ph = Shellwords.escape(Epitrack::Parser::PLACEHOLDER_GLOB)
        pattern = path.sub(escaped_ph, '*')
        files = Dir[pattern]
        if files.size != 1
          STDERR.puts "Non-single candidates for #{pattern}:"
          STDERR.puts files.join("\n")
          raise 'Ambiguous path'
        end

        path = files.first
      end

      path
    end

    # Watch the current episode
    def watch_current!
      ep = ep(@current_ep).watch!
      @current_ep = next_episode.number
      ep
    end

    def current_episode
      ep(@current_ep)
    end

    # Return the next episode after the current
    #
    # @return [Episode] the next episode
    def next_episode
      # Not ep(@current_ep + 1) because episodes are not guaranteed to be in
      # sequence (i.e. we could have episodes 1, 2, 4, 5 etc.)
      idx = @episodes.map(&:number).index(@current_ep)
      if idx + 1 < @episodes.size
        @episodes[idx + 1]
      else
        ep(@current_ep)
      end
    end
  end
end
