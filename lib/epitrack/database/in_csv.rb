require 'epitrack/series'

require 'csv'

class Epitrack
  class Database
    # Database in CSV format
    module InCSV
      module_function

      def read(filename)
        series = []

        return series unless File.exist?(filename)

        CSV.foreach(filename) do |row|
          name, template, current_ep, *history = row
          # Group in three (ep_num, first_watched, last_watched)
          history = history.each_slice(3).to_a

          series.push(Epitrack::Series.new(
            name, history, template: template, current_ep: current_ep
          ))
        end

        series
      end

      def write(filename, all_series)
        CSV.open(filename, 'w') do |csv|
          all_series.each do |series|
            csv << [
              series.name,
              series.template,
              series.current_ep,
              series.episodes.map do |ep|
                [ep.number, ep.first_watched, ep.last_watched]
              end
            ].flatten
          end
        end
      end
    end
  end
end
