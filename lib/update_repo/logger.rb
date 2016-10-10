require 'update_repo/version'
require 'update_repo/helpers'

module UpdateRepo
  # Class : Logger.
  # This class encapsulates printing to screen and logging to file if requried.
  class Logger
    include Helpers

    # Constructor for the Logger class.
    # @param enabled [boolean] True if we log to file
    # @param timestamp [boolean] True if we timestamp the filename
    # @return [void]
    # @example
    #   log = Logger.new(true, false)
    def initialize(enabled, timestamp)
      @settings = { enabled: enabled, timestamp: timestamp }
      # don't prepare a logfile unless it's been requested.
      return unless @settings[:enabled]
      # generate a filename depending on 'timestamp' setting.
      filename = generate_filename
      # open the logfile and set sync mode.
      @logfile = File.open(filename, 'w')
      @logfile.sync = true
    end

    # generate a filename for the log, with or without a timestamp
    # @param [none]
    # @return [string] Filename for the logfile.
    def generate_filename
      if @settings[:timestamp]
        'updaterepo-' + Time.new.strftime('%y%m%d-%H%M%S') + '.log'
      else
        'updaterepo.log'
      end
    end

    # this function will simply pass the given string to 'print', and also
    # log to file if that is specified.
    # @param string [array] Array of strings for print formatting
    # @return [void]
    def output(*string)
      # log to screen regardless
      print(*string)
      # log to file if that has been enabled
      return unless @settings[:enabled]
      @logfile.write(string.join('').gsub(/\e\[(\d+)(;\d+)*m/, ''))
    end

    # close the logfile, if it exists
    # @param [none]
    # @return [void]
    def close
      @logfile.close if @logfile
    end
  end
end
