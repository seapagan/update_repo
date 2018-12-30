require 'update_repo/version'
require 'update_repo/helpers'
require 'update_repo/cmd_config'
require 'update_repo/logger'
require 'update_repo/console_output'
require 'update_repo/metrics'
require 'update_repo/git_control'
require 'yaml'
require 'colorize'
require 'confoog'
require 'trollop'
require 'versionomy'
require 'pp'

# Overall module with classes performing the functionality
# Contains Class UpdateRepo::WalkRepo
module UpdateRepo
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
      @log = Logger.new(@cmd)
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
      String.disable_colorization = !@cmd[:color]
      # check for existence of 'Git' and exit otherwise...
      checkgit
      # print out our header unless we are dumping / importing ...
      @cons.show_header unless dumping?
      config['location'].each do |loc|
        @cmd[:dump_tree] ? dump_tree(File.join(loc)) : recurse_dir(loc)
      end
      # print out an informative footer unless dump / import ...
      @cons.show_footer unless dumping?
    end

    private

    def checkgit
      unless which('git')
        print 'Git is not installed on this machine, script cannot '.red,
              "continue.\n".red
        exit 1
      end
      gitver = `git --version`.gsub(/git version /, '').chomp
      return if Versionomy.parse(gitver) >= '1.8.5'

      print 'Git version 1.8.5 or greater must be installed, you have '.red,
            "version #{gitver}!\n".red
      exit 1
    end

    def dumping?
      @cmd[:dump] || @cmd[:dump_remote] || @cmd[:dump_tree]
    end

    # returns the Confoog class which can then be used to access any config var
    # @return [void]
    # @param [none]
    def config
      @cmd.getconfig
    end

    # take each directory contained in the Repo directory, if it is detected as
    # a Git repository then update it (or as directed by command line)
    # @param dirname [string] Contains the directory to search for Git repos.]
    # @return [void]
    # rubocop:disable LineLength
    def recurse_dir(dirname)
      walk_tree(dirname).each do |repo|
        if dumping?
          dump_repo(repo[:path])
        else
          notexception?(repo[:name]) ? update_repo(repo[:path]) : skip_repo(repo[:path])
        end
      end
    end
    # rubocop:enable LineLength

    # walk the specified tree, return an array of hashes holding valid repos
    # @param dirname [string] Directory to use as the base of the search
    # @return [array] Array of hashes {:path, :name} for discovered Git repos
    def walk_tree(dirname)
      repo_list = []
      Dir.chdir(dirname) do
        Dir['**/'].each do |dir|
          next unless gitdir?(dir)

          repo_list.push(path: File.join(dirname, dir), name: dir)
        end
      end
      repo_list
    end

    # tests to see if the given directory is an exception and should be skipped
    # @param dir [string] Directory to be checked
    # @return [boolean] True if this is NOT an exception, False otherwise
    # ignore the :reek:NilCheck for this function, may refactor later
    def notexception?(dir)
      return true if @cmd.true_cmd(:exceptions).nil?

      !config['exceptions'].include?(File.basename(dir))
    end

    # Takes the specified Repo and does not update it, outputing a note to the
    # console / log to this effect.
    # @param dirpath [string] The directory with Git repository to be skipped
    # @return [void]
    # @example
    #   skip_repo('/Repo/Personal/work-in-progress')
    def skip_repo(dirpath)
      repo_url = `git -C #{dirpath} config remote.origin.url`.chomp
      print_log '* Skipping ', dirpath.yellow, " (#{repo_url})\n"
      @metrics[:skipped] += 1
      @log.repostat(skipped: true)
      @metrics[:processed] += 1
    end

    # Takes the specified Repo outputs information and the repo URL then calls
    # #do_update to actually update it.
    # @param dirname [string] The directory that will be updated
    # @return [void]
    # @example
    #   update_repo('/Repo/linux/stable')
    def update_repo(dirpath)
      # create the git instance and then perform the update
      git = GitControl.new(dirpath, @log, @metrics, @cmd)
      git.update
      @metrics[:processed] += 1
      # update the metrics
      [:failed, :updated, :unchanged, :warning].each do |metric|
        @metrics[metric] += 1 if git.status[metric]
      end
      @log.repostat(git.status)
    end

    # this function will either dump out a CSV with the directory and remote,
    # or just the remote depending if we called --dump or --dump-remote
    # @param dir [string] The local directory for the repository
    # @return [void]
    def dump_repo(dir)
      Dir.chdir(dir.chomp!('/')) do
        print_log "#{trunc_dir(dir, @cmd[:prune])}," if @cmd[:dump]
        print_log `git -C #{dir} config remote.origin.url`
      end
    end

    # This function will recurse though all the subdirectories of the specified
    # directory and print only the directory name in a tree format.
    def dump_tree(dir)
      print "here for #{dir}\n"
    end
  end
end
