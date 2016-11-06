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
    # @param verbose [boolean] True if verbose flag is set
    # @return [void]
    # @example
    #   log = Logger.new(true, false)
    def initialize(enabled, timestamp, verbose)
      @settings = { enabled: enabled, timestamp: timestamp, verbose: verbose }
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
      # log header and footer to screen regardless, others only if verbose
      if @settings[:verbose] || !repo_text?
        print(*string)
      else
        # remove control characters from the string...
        string = string.join.gsub(/\e\[(\d+)(;\d+)*m/, '').strip
        case repo_text?
        when 'skip_repo'
          print 's'.yellow
        when 'handle_err'
          print 'x'.red
        when 'handle_output'
          # print string
          if string =~ /^Updating\s[0-9a-f]{7}\.\.[0-9a-f]{7}/
            print '^'.green
          elsif string =~ /Already up-to-date./
            print '.'
          end
        end
      end
      # log to file if that has been enabled
      return unless @settings[:enabled]
      @logfile.write(string.join('').gsub(/\e\[(\d+)(;\d+)*m/, ''))
    end

    # returns non nil if we have been called originally by one of the Repo
    # update output functions.
    # @param [none]
    # @return [boolean] True if we have been called during repo update
    def repo_text?
      # get calling function - need to skip first 2, also remove 'block in '
      # prefix if exists
      calling_fn = caller_locations[2].label.gsub(/block in /, '')

      # array with the functions we want to skip
      repo_output = %w(do_update handle_output handle_err skip_repo)

      # return the name in string if DOES match.
      calling_fn if repo_output.include?(calling_fn)
    end

    # close the logfile, if it exists
    # @param [none]
    # @return [void]
    def close
      @logfile.close if @logfile
    end
  end
end
