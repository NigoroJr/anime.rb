require 'epitrack/series'

require 'unicode/display_width'

class Epitrack
  # A module for tabulating the list of series.
  module Tabulate
    module_function

    # Tabulates the given list of series
    #
    # @param series [Array<Series>] the list of series to show.
    #
    # @param to_show [Array<Symbol>] the columns to show. If :all is
    #   specified, it is equivalent to [:name, :template, :current_ep,
    #   :final_ep, :start_date, :finish_date]. UNIMPLEMENTED.
    #
    # @return [String] tabulated string. Empty if none.
    def tabulate(series, to_show = [:all])
      return '' if series.empty?

      if to_show == [:all]
        to_show = [
          :name,
          :current_ep,
          :final_ep,
          :started_at,
          :finished_at,
          :template
        ]
      end

      labels = %w(Name Next Final Started Finished Template)

      # Width of each column
      widths = get_widths(series, to_show)
      labels.each_with_index do |label, i|
        widths[i] = label.size if widths[i] < label.size
      end

      rows = []

      row = labels.each_with_index.map { |label, i| ljust(label, widths[i]) }
      rows << row.join(' | ')

      series.each do |s|
        values = to_show.map { |attr| s.send(attr) }

        row = []
        values.each_with_index do |attr, i|
          str = attr.is_a?(DateTime) ? attr.strftime('%F') : attr.to_s
          row << ljust(str, widths[i])
        end

        rows << row.join(' | ')
      end
      rows.join("\n")
    end

    private

    module_function

    # Finds out the needed width for each column
    # DateTime instances are printed in the "%Y-%m-%d" format.
    #
    # @param series [Array<Series>] the list of series to show.
    #
    # @param to_show [Array<Symbol>] the information to show.
    #
    # @return [Array<Integer>] width necessary for each column.
    def get_widths(series, to_show)
      widths = []
      to_show.each do |col|
        max = series.max do |a, b|
          a = a.send(col)
          b = b.send(col)
          a_str = a.is_a?(DateTime) ? a.strftime('%F') : a.to_s
          b_str = b.is_a?(DateTime) ? b.strftime('%F') : b.to_s

          a_str.display_width <=> b_str.display_width
        end

        max = max.send(col)
        max_str = max.is_a?(DateTime) ? max.strftime('%F') : max.to_s
        widths << max_str.display_width
      end
      widths
    end

    # Left-justifies taking unicode width into consideration
    def ljust(str, width)
      spaces = width - str.display_width
      spaces = width if spaces < 0
      str + ' ' * spaces
    end
  end
end
