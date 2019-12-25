# frozen_string_literal: true

require 'update_repo/version'
require 'update_repo/helpers'
require 'yaml'

module UpdateRepo
  # Class : Metrics.
  # This class takes care of storing the metrics for processed, failures, etc.
  class Metrics
    include Helpers

    # Constructor for the Metrics class.
    # @return [instance] Instance of the Metrics class
    # def initialize(logger)
    def initialize
      @metrics = { processed: 0, skipped: 0, failed: 0, updated: 0,
                   unchanged: 0, start_time: 0, failed_list: [],
                   warning: 0 }
    end

    # Read the metric 'key'
    # @param key [symbol] the key to read
    # @return [various] Return the value for hash key 'key'
    def [](key)
      @metrics[key]
    end

    # Set the metric 'key' to 'value'
    # @param key [symbol] the key to set
    # @param value [symbol] set 'key' to this value.
    # @return [value] Return the value set.
    def []=(key, value)
      @metrics[key] = value
    end

    # This will save any (git) errors encountered to a file,
    # so they can be reprinted again at a later date.
    # If no errors, then delete any previously existing error file.
    def save_errors(config)
      path = config.config_path + '.errors'
      if @metrics[:failed_list].empty?
        # delete any existing  file
        File.delete(path) if File.exist(path)
      else
        # get the location of the config file, we'll use the same dir
        # and base name
        File.open(path, 'w') { |file| file.write @metrics[:failed_list].to_yaml }
      end
    end

    # loads an error file (if exists) into the @metrics[:failed_list].
    def load_errors(config)
      path = config.config_path + '.errors'
      @metrics[:failed_list] = YAML.load_file(path) if File.exist?(path)
    end
  end
end
