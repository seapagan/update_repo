require 'update_repo/version'
require 'update_repo/helpers'
require 'open3'

module UpdateRepo
  # Class : GitControl.
  # This class will update one git repo, and send the output to the logger.
  # It will also return status of the operation in #status.
  class GitControl
    include Helpers

    # @return [hash] Return the status hash
    attr_reader :status

    # Constructor for the GitControl class.
    # @param dir [string] The directory location of this local repo.
    # @param logger [instance] pointer to the Logger class
    # @param metrics [instance] pointer to the Metrics class
    # @return [void]
    # @example
    #   git = GitControl.new(repo_url, @logger, @metrics)
    def initialize(dir, logger, metrics)
      @status = { updated: false, failed: false, unchanged: false }
      @dir = dir
      @log = logger
      @metrics = metrics
    end

    # Update the git repo that was specified in the initializer.
    # @param [none]
    # @return [void]
    def update
      print_log '* Checking ', @dir.green, " (#{repo_url})\n"
      Open3.popen2e("git -C #{@dir} pull") do |_stdin, stdout_err, _thread|
        stdout_err.each { |line| handle_output(line) }
      end
      # reset the updated status in the rare case than both update and failed
      # are set. This does happen!
      @status[:updated] = false if @status[:updated] && @status[:failed]
    end

    private

    # Returns the repo remote url for the repo in @dir
    # @param [none]
    # @return [string]
    def repo_url
      `git -C #{@dir} config remote.origin.url`.chomp
    end

    # adds a line to the fail matrix (with it's location) if it does not already
    # exist, otherwise it will add the line to the end of the previous for that
    # location
    # @param lin [string] The string containing the Git output line
    # @return [void]
    def update_fail_matrix(line)
      err_loc = "#{@dir} (#{repo_url})"
      # see if this error already has some text (metric exists)
      err = @metrics[:failed_list].find { |fail| fail[:loc] == err_loc }
      # if so we append this new line to it otherwise create the metric
      if err
        err[:line] = err[:line] + ' ' * 7 + line
      else
        @metrics[:failed_list].push(loc: err_loc, line: line)
      end
    end

    # print a git output line and update the metrics if an update has occurred
    # @param line [string] The string containing the git output line
    # @return [void]
    # rubocop:disable Metrics/LineLength
    def handle_output(line)
      @status[:failed] = true if line.chomp =~ /^fatal:|^error:/
      # @status[:failed] will persist throughout this entire git call.
      if @status[:failed]
        print_log ' ' * 3, line.red
        # add new or update the fail matrix with another line
        update_fail_matrix(line)
      else
        print_log ' ' * 3, line.cyan
        @status[:updated] = true if line =~ /^Updating\s[0-9a-f]{7}\.\.[0-9a-f]{7}/
        @status[:unchanged] = true if line =~ /^Already up-to-date./
      end
    end
    # rubocop:enable Metrics/LineLength
  end
end
