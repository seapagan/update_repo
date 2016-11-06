require 'update_repo/version'
require 'update_repo/helpers'

module UpdateRepo
  # Class : Metrics.
  # This class takes care of storing the metrics for processed, failures, etc.
  class Metrics
    include Helpers

    # Constructor for the Metrics class.
    # @param logger [instance] Pointer to the Logger class
    # @return [instance] Instance of the Metrics class
    def initialize(logger)
      @log = logger
      @metrics = { processed: 0, skipped: 0, failed: 0, updated: 0,
                   start_time: 0, failed_list: [] }
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

    # output an error line and update the metrics
    # @param line [string] The string containing the error message
    # @return [void]
    def handle_err(line)
      return unless line =~ /^fatal:|^error:/
      print_log '   ', line.red
      @metrics[:failed] += 1
      err_loc = Dir.pwd + " (#{repo_url})"
      @metrics[:failed_list].push(loc: err_loc, line: line)
    end

    # print a git output line and update the metrics if an update has occurred
    # @param line [string] The string containing the git output line
    # @return [void]
    def handle_output(line)
      print_log '   ', line.cyan
      # @metrics[:updated] += 1 if line =~ %r{^From\s(?:https?|git)://}
      @metrics[:updated] += 1 if line =~ /^Updating\s[0-9a-f]{7}\.\.[0-9a-f]{7}/
    end
  end
end
