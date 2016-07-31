require 'update_repo/version'
require 'update_repo/helpers'
require 'update_repo/cmd_config'
require 'yaml'
require 'colorize'
require 'confoog'
require 'trollop'
require 'open3'

# Overall module with classes performing the functionality
# Contains Class UpdateRepo::WalkRepo
module UpdateRepo
  # This constant holds the name to the config file, located in ~/
  CONFIG_FILE = '.updaterepo'.freeze

  # An encapsulated class to walk the repo directories and update all Git
  # repositories found therein.
  # rubocop:disable Metrics/ClassLength
  class WalkRepo
    include Helpers
    # Class constructor. No parameters required.
    # @return [void]
    def initialize
      @metrics = { processed: 0, skipped: 0, failed: 0, updated: 0,
                   start_time: 0 }
      @summary = { processed: 'green', updated: 'cyan', skipped: 'yellow',
                   failed: 'red' }
      # create a new instance of the CmdConfig class then read the config var
      @cmd = CmdConfig.new
      # set up the logfile if needed
      setup_logfile if cmd('log')
    end

    # This function will perform the required actions to traverse the Repo.
    # @example
    #   walk_repo = UpdateRepo::WalkRepo.new
    #   walk_repo.start
    def start
      String.disable_colorization = true unless cmd('color')
      # make sure we dont have bad cmd-line parameter combinations ...
      @cmd.check_params
      # print out our header unless we are dumping / importing ...
      no_header = cmd('dump') || cmd('import')
      show_header unless no_header
      config['location'].each do |loc|
        recurse_dir(loc)
      end
      # print out an informative footer unless dump / import ...
      footer unless no_header
    end

    # private

    # returns the Confoog class which can then be used to access any config var
    def config
      @cmd.getconfig
    end

    def cmd(command)
      config['cmd'][command.to_sym] || config[command]
    end

    def setup_logfile
      filename = if cmd('timestamp')
                   'updaterepo-' + Time.new.strftime('%y%m%d-%H%M%S') + '.log'
                 else
                   'updaterepo.log'
                 end
      @logfile = File.open(filename, 'w')
      @logfile.sync = true
    end

    # take each directory contained in the Repo directory, if it is detected as
    # a Git repository then update it (or as directed by command line)
    # @param dirname [string] Contains the directory to search for Git repos.
    def recurse_dir(dirname)
      Dir.chdir(dirname) do
        Dir['**/'].each do |dir|
          next unless gitdir?(dir)
          if cmd('dump')
            dump_repo(File.join(dirname, dir))
          else
            notexception?(dir) ? update_repo(dir) : skip_repo(dir)
          end
        end
      end
    end

    # tests to see if the given directory is an exception and should be skipped
    # @param dir [string] Directory to be checked
    # @return [boolean] True if this is NOT an exception, False otherwise
    def notexception?(dir)
      !config['exceptions'].include?(File.basename(dir))
    end

    # Display a simple header to the console
    # @example
    #   show_header
    # @return [void]
    def show_header
      # print an informative header before starting
      print_log "\nGit Repo update utility (v", VERSION, ')',
                " \u00A9 Grant Ramsay <seapagan@gmail.com>\n"
      print_log "Using Configuration from '#{config.config_path}'\n"
      # print_log "Command line is : #{config['cmd']}\n"
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
    def footer
      duration = Time.now - @metrics[:start_time]
      print_log "\nUpdates completed in ", show_time(duration).cyan
      print_metrics
      print_log " |\n\n"
      # close the log file now as we are done, just to be sure ...
      @logfile.close if @logfile
    end

    def print_metrics
      @summary.each do |metric, color|
        metric_value = @metrics[metric]
        output = "#{metric_value} #{metric.capitalize}"
        print_log ' | ', output.send(color.to_sym) unless metric_value.zero?
      end
    end

    def list_exceptions
      exceptions = config['exceptions']
      if exceptions
        print_log "\nExclusions:".underline, ' ',
                  exceptions.join(', ').yellow, "\n"
      end
    end

    def list_locations
      print_log "\nRepo location(s):\n".underline
      config['location'].each do |loc|
        print_log '-> ', loc.cyan, "\n"
      end
    end

    def skip_repo(dirpath)
      Dir.chdir(dirpath.chomp!('/')) do
        repo_url = `git config remote.origin.url`.chomp
        print_log '* Skipping ', Dir.pwd.yellow, " (#{repo_url})\n"
        @metrics[:skipped] += 1
      end
    end

    def update_repo(dirname)
      Dir.chdir(dirname.chomp!('/')) do
        repo_url = `git config remote.origin.url`.chomp
        do_update(repo_url)
        @metrics[:processed] += 1
      end
    end

    def do_update(repo_url)
      print_log '* Checking ', Dir.pwd.green, " (#{repo_url})\n"
      Open3.popen3('git pull') do |stdin, stdout, stderr, thread|
        stdin.close
        do_threads(stdout, stderr)
        thread.join
      end
    end

    def do_threads(stdout, stderr)
      { out: stdout, err: stderr }.each do |key, stream|
        Thread.new do
          while (line = stream.gets)
            if key == :err && line =~ /^fatal:/
              print_log '   ', line.red
              @metrics[:failed] += 1
            else
              print_log '   ', line.cyan
              @metrics[:updated] += 1 if line =~ %r{^From\s(?:https?|git)://}
            end
          end
        end
      end
    end

    def dump_repo(dir)
      Dir.chdir(dir.chomp!('/')) do
        repo_url = `git config remote.origin.url`.chomp
        print_log "#{trunc_dir(dir, config['cmd'][:prune])},#{repo_url}\n"
      end
    end
  end
end
