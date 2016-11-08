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
    # @param config [class] Pointer to the Confoog class
    # @return [void]
    # @example
    #   console = ConsoleOutput.new(@log)
    def initialize(logger, metrics, config)
      @summary = { processed: 'green', updated: 'cyan', skipped: 'yellow',
                   failed: 'red', unchanged: 'white' }
      @metrics = metrics
      @log = logger
      @config = config.getconfig
    end

    # Display a simple header to the console
    # @example
    #   show_header
    # @return [void]
    # @param [none]
    def show_header
      # print an informative header before starting
      print_log "\nGit Repo update utility (v", VERSION, ')',
                " \u00A9 Grant Ramsay <seapagan@gmail.com>\n"
      print_log "Using Configuration from '#{@config.config_path}'\n"
      # list out the locations that will be searched
      list_locations
      # list any exceptions that we have from the config file
      list_exceptions
      # save the start time for later display in the footer...
      @metrics[:start_time] = Time.now
      print_log "\n" # blank line before processing starts
    end

    # print out a brief footer. This will be expanded later.
    # @return [void]
    # @param [none]
    def show_footer
      duration = Time.now - @metrics[:start_time]
      print_log "\nUpdates completed in ", show_time(duration).cyan
      print_metrics
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
        output = "#{metric_value} #{metric.capitalize}"
        print_log ' | ', output.send(color.to_sym) unless metric_value.zero?
      end
      print_log ' |'
      list_failures unless @metrics[:failed_list].empty?
    end

    # List any repositories that failed their update, and the error.
    # @param [none]
    # @return [void]
    def list_failures
      print_log "\n\n!! Note : The following #{@metrics[:failed_list].count}",
                ' repositories ', 'FAILED'.red.underline, ' during this run :'
      # ensure we don't have duplicate errors from the same repo
      @metrics[:failed_list].uniq! { |x| x[:loc] }
      # print out any and all errors into a nice list
      @metrics[:failed_list].each do |failed|
        print_log "\n  [", 'x'.red, "] #{failed[:loc]}"
        print_log "\n    -> ", "\"#{failed[:line].chomp}\"".red
      end
    end

    # Print a list of any defined expections that will not be updated.
    # @return [void]
    # @param [none]
    def list_exceptions
      exceptions = @config['exceptions']
      return unless exceptions
      print_log "\nExclusions:".underline, ' ',
                exceptions.join(', ').yellow, "\n"
    end

    # Print a list of all top-level directories that will be searched and any
    # Git repos contained within updated.
    # @return [void]
    def list_locations
      print_log "\nRepo location(s):\n".underline
      @config['location'].each do |loc|
        print_log '-> ', loc.cyan, "\n"
      end
    end
  end
end
