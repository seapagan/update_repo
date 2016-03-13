require 'update_repo/version'
require 'yaml'
require 'colorize'
require 'confoog'

# Overall module with classes performing the functionality
# Contains Class UpdateRepo::WalkRepo
module UpdateRepo
  # This constant holds the name to the config file, located in ~/
  CONFIG_FILE = '.updatereporc'.freeze

  # An encapsulated class to walk the repo directories and update all Git
  # repositories found therein.
  class WalkRepo
    # Read-only attribute holding the total number of traversed repositories
    # @attr_reader :counter [fixnum] total number of traversed repositories
    attr_reader :counter

    # Class constructor. No parameters required.
    # @return [void]
    def initialize
      # @counter - this will be incremented with each repo updated.
      @counter = 0
      # @ start_time - will be used to get elapsed time
      @start_time = 0
      # @config - Class. Reads the configuration from a file in YAML format and
      # allows easy access to the configuration data
      @config = Confoog::Settings.new(filename: '.updatereporc',
                                      prefix: 'update_repo',
                                      autoload: true)
      exit 1 unless @config.status[:errors] == Status::INFO_FILE_LOADED
    end

    # This function will perform the required actions to traverse the Repo.
    # @example
    #   walk_repo = UpdateRepo::WalkRepo.new
    #   walk_repo.start
    def start
      exceptions = @config['exceptions']
      show_header(exceptions)
      @config['location'].each do |loc|
        recurse_dir(loc, exceptions)
      end
      # print out an informative footer...
      footer
    end

    private

    # take each directory contained in the Repo directory, and if it is detected
    # as a Git repository then update it.
    # @param dirname [string] Contains the directory to search for Git repos.
    # @param exceptions [array] Each repo matching one of these will be ignored.
    def recurse_dir(dirname, exceptions)
      Dir.foreach(dirname) do |dir|
        dirpath = dirname + '/' + dir
        next unless File.directory?(dirpath) && notdot?(dir)
        if gitdir?(dirpath)
          !exceptions.include?(dir) ? update_repo(dirpath) : skip_dir(dirpath)
        else
          recurse_dir(dirpath, exceptions)
        end
      end
    end

    # Display a simple header to the console
    # @example
    #   show_header(exceptions)
    # @return [void]
    def show_header(exceptions)
      # print an informative header before starting
      print "\nGit Repo update utility (v", VERSION, ')',
            " \u00A9 Grant Ramsay <seapagan@gmail.com>\n"
      print "Using Configuration from '#{@config.config_path}'\n"
      list_locations
      if exceptions
        print "\nExclusions:".underline, ' ',
              exceptions.join(', ').yellow, "\n"
      end
      # save the start time for later display in the footer...
      @start_time = Time.now
      print "\n" # blank line before processing starts
    end

    # print out a brief footer. This will be expanded later.
    # @return [void]
    def footer
      duration = Time.now - @start_time
      print "\nUpdates completed - ", "#{@counter}".yellow, " repositories ",
            "processed in ", show_time(duration)
    end

    def show_time(duration)
      "#{Time.at(duration).utc.strftime('%H:%M:%S')}\n\n".cyan
    end

    def list_locations
      print "\nRepo location(s):\n".underline
      @config['location'].each do |loc|
        print '-> ', loc.cyan, "\n"
      end
    end

    def skip_dir(dirpath)
      Dir.chdir(dirpath) do
        repo_url = `git config remote.origin.url`.chomp
        print "* Skipping #{dirpath}".yellow, " (#{repo_url})\n"
      end
    end

    def update_repo(dirname)
      Dir.chdir(dirname) do
        repo_url = `git config remote.origin.url`.chomp
        print '* ', 'Checking ', dirname.green, " (#{repo_url})\n", '  -> '
        system 'git pull'
        @counter += 1
      end
    end

    def gitdir?(dirpath)
      gitpath = dirpath + '/.git'
      File.exist?(gitpath) && File.directory?(gitpath)
    end

    def notdot?(dir)
      (dir != '.' && dir != '..')
    end
  end
end
