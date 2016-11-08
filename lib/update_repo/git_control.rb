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
      Open3.popen3("git -C #{@dir} pull") do |stdin, stdout, stderr, thread|
        stdin.close
        do_threads(stdout, stderr)
        thread.join
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

    # Create 2 individual threads to handle both STDOUT and STDERR streams,
    # writing to console and log if specified.
    # @param stdout [stream] STDOUT Stream from the popen3 call
    # @param stderr [stream] STDERR Stream from the popen3 call
    # @return [void]
    def do_threads(stdout, stderr)
      { out: stdout, err: stderr }.each do |key, stream|
        Thread.new do
          while (line = stream.gets)
            handle_err(line) if key == :err
            handle_output(line) if key == :out
          end
        end
      end
    end

    # output an error line and update the metrics
    # @param line [string] The string containing the error message
    # @return [void]
    def handle_err(line)
      return unless line =~ /^fatal:|^error:/
      print_log '   ', line.red
      @status[:failed] = true
      err_loc = "#{@dir} (#{repo_url})"
      @metrics[:failed_list].push(loc: err_loc, line: line)
    end

    # print a git output line and update the metrics if an update has occurred
    # @param line [string] The string containing the git output line
    # @return [void]
    # rubocop:disable Metrics/LineLength
    def handle_output(line)
      print_log '   ', line.cyan
      @status[:updated] = true if line =~ /^Updating\s[0-9a-f]{7}\.\.[0-9a-f]{7}/
      @status[:unchanged] = true if line =~ /^Already up-to-date./
    end
    # rubocop:enable Metrics/LineLength
  end
end
