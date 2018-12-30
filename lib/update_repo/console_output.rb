require 'update_repo/version'
require 'update_repo/helpers'

module UpdateRepo
  # Class : ConsoleOutput.
  # This class has functions to print header, footer and metrics.
  class ConsoleOutput
    include Helpers

    # Constructor for the ConsoleOutput class.
    # @param logger [class] Pointer to the Logger class
    # @param metrics [class] Pointer to the Metrics class
    # @param cmd [class] Pointer to the CmdConfig class
    # @return [void]
    # @example
    #   console = ConsoleOutput.new(@log)
    def initialize(logger, metrics, cmd)
      @summary = { processed: 'green', updated: 'cyan', skipped: 'yellow',
                   failed: 'red', unchanged: 'white', warning: 'light_magenta' }
      @metrics = metrics
      @log = logger
      @cmd = cmd
    end

    # Display a simple header to the console
    # @example
    #   show_header
    # @return [void]
    # @param [none]
    def show_header
      unless @cmd[:brief]
        # print an informative header before starting
        print_log "\nGit Repo update utility (v", VERSION, ')',
                  " \u00A9 Grant Ramsay <seapagan@gmail.com>\n"
        print_log "Using Configuration from '#{@cmd.getconfig.config_path}'\n"
        # show the logfile location, but only if it is enabled
        show_logfile
        # list out the locations that will be searched
        list_locations
        # list any exceptions that we have from the config file
        list_exceptions
        # save the start time for later display in the footer...
        @metrics[:start_time] = Time.now
      end
      print_log "\n" # blank line before processing starts
    end

    # print out a brief footer. This will be expanded later.
    # @return [void]
    # @param [none]
    def show_footer
      unless @cmd[:brief]
        duration = Time.now - @metrics[:start_time]
        print_log "\n\nUpdates completed in ", show_time(duration).cyan
        print_metrics
      end
      print_log " \n\n"
      # close the log file now as we are done, just to be sure ...
      @log.close
    end

    # Print end-of-run metrics to console / log
    # @return [void]
    # @param [none]
    def print_metrics
      @summary.each do |metric, color|
        metric_value = @metrics[metric]
        output = pluralize(metric_value, metric)
        print_log ' | ', output.send(color.to_sym) unless metric_value.zero?
      end
      print_log ' |'
      list_failures unless @metrics[:failed_list].empty?
    end

    # List any repositories that failed their update, and the error.
    # @param [none]
    # @return [void]
    def list_failures
      # ensure we don't have duplicate errors from the same repo
      remove_dups
      print_log "\n\n!! Note : The following #{@metrics[:failed_list].count}",
                ' repositories ', 'FAILED'.red.underline, ' during this run :'
      # print out any and all errors into a nice list
      @metrics[:failed_list].each do |failed|
        print_log "\n  [", 'x'.red, "] #{failed[:loc]}"
        print_log "\n    -> ", failed[:line].chomp.red
      end
    end

    # removes any duplications in the list of failed repos.
    # @param [none]
    # @return [void] modifies the @metrics[:failed_list] in place
    def remove_dups
      # removes duplicate ':loc' values from the Failed list.
      @metrics[:failed_list].uniq! { |error| error[:loc] }
    end

    # Print a list of any defined exceptions that will not be updated.
    # @return [void]
    # @param [none]
    def list_exceptions
      exceptions = @cmd['exceptions']
      return unless exceptions

      print_log "\nExclusions:".underline, ' ',
                exceptions.join(', ').yellow, "\n"
    end

    # Print a list of all top-level directories that will be searched and any
    # Git repos contained within updated.
    # @return [void]
    def list_locations
      print_log "\nRepo location(s):\n".underline
      @cmd['location'].each do |loc|
        print_log '-> ', loc.cyan, "\n"
      end
    end

    # print out the logfile name and location, if we are logging to file
    # @return [void]
    def show_logfile
      return unless @cmd[:log]

      print_log "\nLogging to file:".underline, " #{@log.logfile}\n".cyan
    end
  end
end
