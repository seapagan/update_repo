require 'update_repo/version'
require 'update_repo/helpers'

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
  end
end
