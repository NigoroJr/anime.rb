require 'epitrack/version'
require 'epitrack/parser'
require 'epitrack/series'
require 'epitrack/database'
require 'epitrack/tabulate'

# A class that keeps track of where the series is located, which episode has
# been played most recently, etc.
class Epitrack
  # The path to the database file.
  attr_reader :database

  def initialize(db_filename)
    @database = Epitrack::Database.new(db_filename)
  end

  # Tabulate unfinished series
  #
  # @return [String] Table of unfinished series.
  def tabulate
    matching =
      if block_given?
        @database.series.select do |series|
          yield series
        end
      else
        @database.series.select do |series|
          !series.finished?
        end
      end

    Epitrack::Tabulate.tabulate(matching)
  end

  # Adds a new series
  #
  # @param name [String] the name of the series
  #
  # @param template [String] the template
  #
  # @param first_ep [Integer] the first episode number
  #
  # @param last_ep [Integer] the last episode number
  def add(name, template, first_ep, last_ep)
    # Create history with empty first_watched and last_watched
    history = first_ep.upto(last_ep).map { |n| [n, nil, nil] }

    series = Epitrack::Series.new(
      name, history, template: template, current_ep: first_ep
    )

    @database.series.push(series)
  end

  def series
    @database.series
  end

  def [](series_name)
    @database[series_name]
  end
end
