require 'update_repo/version'
require 'update_repo/helpers'

module UpdateRepo
  # Class : Logger.
  # This class encapsulates printing to screen and logging to file if requried.
  class Logger
    include Helpers

    # Constructor for the Logger class.
    # @param cmd [instance] - pointer to the CmdConfig class
    # @return [void]
    # @example
    #   log = Logger.new(@cmd)
    def initialize(cmd)
      @cmd = cmd
      @legend = { failed: { char: 'x', color: 'red' },
                  updated: { char: '^', color: 'green' },
                  unchanged: { char: '.', color: 'white' },
                  skipped: { char: 's', color: 'yellow' } }
      # don't prepare a logfile unless it's been requested.
      return unless @cmd[:log]
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
      if @cmd[:timestamp]
        name = 'updaterepo-' + Time.new.strftime('%y%m%d-%H%M%S') + '.log'
      else
        name = 'updaterepo.log'
      end
      File.expand_path(File.join('~/', name))
    end

    # this function will simply pass the given string to 'print', and also
    # log to file if that is specified.
    # @param string [array] Array of strings for print formatting
    # @return [void]
    def output(*string)
      # nothing to screen if we want to be --quiet
      unless @cmd[:quiet]
        # log header and footer to screen regardless
        print(*string) if @cmd[:verbose] || !repo_text?
      end
      # log to file if that has been enabled
      return unless @cmd[:log]
      @logfile.write(string.join('').gsub(/\e\[(\d+)(;\d+)*m/, ''))
    end

    # function repostat - outputs a coloured char depending on the status hash,
    # but not if we are in quiet or verbose mode.
    # @param status [hash] pointer to GitControl.status hash
    # @return [void]
    def repostat(status)
      # only print if not quiet and not verbose!
      return if @cmd[:quiet] || @cmd[:verbose]
      @legend.each do |key, value|
        print value[:char].send(value[:color].to_sym) if status[key]
      end
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
      repo_output = %w(do_update handle_output skip_repo update)
      # return TRUE if DOES match, FALSE otherwise.
      repo_output.include?(calling_fn) ? true : false
    end

    # close the logfile, if it exists
    # @param [none]
    # @return [void]
    def close
      @logfile.close if @logfile
    end
  end
end
