require 'epitrack/database/in_csv'

class Epitrack
  # A class for managing information about all the series.
  class Database
    attr_reader :filename
    attr_reader :series

    def initialize(filename)
      @filename = filename

      case File.extname(@filename)[1..-1]
      when 'csv'
        @series = Epitrack::Database::InCSV.read(@filename)
      else
        raise 'Unsupported database format'
      end
    end

    def each(&block)
      @series.each(block)
    end

    def write!
      case File.extname(@filename)[1..-1]
      when 'csv'
        Epitrack::Database::InCSV.write(@filename, @series)
      else
        raise 'Unsupported database format'
      end
    end

    def size
      @series.size
    end

    def [](series_name)
      idx = @series.map(&:name).index(series_name)
      return nil if idx.nil?
      @series[idx]
    end
  end
end
