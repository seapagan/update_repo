require 'update_repo/version'
require 'update_repo/helpers'
require 'update_repo/cmd_config'
require 'update_repo/logger'
require 'update_repo/console_output'
require 'update_repo/metrics'
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
  class WalkRepo
    include Helpers
    # Class constructor. No parameters required.
    # @return [void]
    def initialize
      # create a new instance of the CmdConfig class then read the config var
      @cmd = CmdConfig.new
      # set up the output and logging class
      @log = Logger.new(cmd(:log), cmd(:timestamp))
      # create instance of the Metrics class
      @metrics = Metrics.new(@log)
      # instantiate the console output class for header, footer etc
      @cons = ConsoleOutput.new(@log, @metrics, @cmd)
    end

    # This function will perform the required actions to traverse the Repo.
    # @example
    #   walk_repo = UpdateRepo::WalkRepo.new
    #   walk_repo.start
    def start
      String.disable_colorization = !cmd(:color)
      # print out our header unless we are dumping / importing ...
      @cons.show_header unless dumping?
      config['location'].each do |loc|
        cmd(:dump_tree) ? dump_tree(File.join(loc)) : recurse_dir(loc)
      end
      # print out an informative footer unless dump / import ...
      @cons.show_footer unless dumping?
    end

    private

    def dumping?
      cmd(:dump) || cmd(:dump_remote) || cmd(:dump_tree)
    end

    # returns the Confoog class which can then be used to access any config var
    # @return [void]
    # @param [none]
    def config
      @cmd.getconfig
    end

    # Return the true value of the specified configuration parameter. This is a
    # helper function that simply calls the 'true_cmd' function in the @cmd
    # class
    # @param command [symbol] The defined command symbol that is to be returned
    # @return [various] The value of the requested command option
    # @example
    #   logging = cmd(:log)
    def cmd(command)
      @cmd.true_cmd(command.to_sym)
    end

    # take each directory contained in the Repo directory, if it is detected as
    # a Git repository then update it (or as directed by command line)
    # @param dirname [string] Contains the directory to search for Git repos.]
    # @return [void]
    def recurse_dir(dirname)
      Dir.chdir(dirname) do
        Dir['**/'].each do |dir|
          next unless gitdir?(dir)
          if dumping?
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

    # Takes the specified Repo and does not update it, outputing a note to the
    # console / log to this effect.
    # @param dirpath [string] The directory with Git repository to be skipped
    # @return [void]
    # @example
    #   skip_repo('/Repo/Personal/work-in-progress')
    def skip_repo(dirpath)
      Dir.chdir(dirpath.chomp!('/')) do
        repo_url = `git config remote.origin.url`.chomp
        print_log '* Skipping ', Dir.pwd.yellow, " (#{repo_url})\n"
        @metrics[:skipped] += 1
      end
    end

    # Takes the specified Repo outputs information and the repo URL then calls
    # #do_update to actually update it.
    # @param dirname [string] The directory that will be updated
    # @return [void]
    # @example
    #   update_repo('/Repo/linux/stable')
    def update_repo(dirname)
      Dir.chdir(dirname.chomp!('/')) do
        do_update
        @metrics[:processed] += 1
      end
    end

    # Actually perform the update of this specific repository, calling the
    # function #do_threads to handle the output to screen and log.
    # @param none
    # @return [void]
    def do_update
      # repo_url = `git config remote.origin.url`.chomp
      print_log '* Checking ', Dir.pwd.green, " (#{repo_url})\n"
      Open3.popen3('git pull') do |stdin, stdout, stderr, thread|
        stdin.close
        do_threads(stdout, stderr)
        thread.join
      end
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
            @metrics.handle_err(line) if key == :err
            @metrics.handle_output(line) if key == :out
          end
        end
      end
    end

    # this function will either dump out a CSV with the directory and remote,
    # or just the remote depending if we called --dump or --dump-remote
    # @param dir [string] The local directory for the repository
    # @return [void]
    def dump_repo(dir)
      Dir.chdir(dir.chomp!('/')) do
        print_log "#{trunc_dir(dir, config['cmd'][:prune])}," if cmd(:dump)
        print_log "#{get_repo_url}\n"
      end
    end

    # This function will recurse though all the subdirectories of the specified
    # directory and print only the directory name in a tree format.
    def dump_tree(dir)
      print "here for #{dir}\n"
    end
  end
end
