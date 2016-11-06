require 'date'

class Epitrack
  # Represents an episode.
  class Episode
    attr_reader :number
    attr_reader :first_watched
    attr_reader :last_watched

    def initialize(number, first_watched = nil, last_watched = nil)
      @number = number.to_i
      @first_watched = to_datetime(first_watched)
      @last_watched = to_datetime(last_watched)
    end

    def watch!
      @last_watched = DateTime.now

      @first_watched = @last_watched if @first_watched.nil?
      self
    end

    def watched?
      !@last_watched.nil?
    end

    private

    def to_datetime(datetime)
      return datetime if datetime.is_a?(DateTime)
      return nil if datetime.nil? || datetime.empty? || datetime == 'nil'

      DateTime.parse(datetime.to_s)
    end
  end
end
