require 'update_repo/version'
require 'yaml'
require 'colorize'
require 'update_repo/version'

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
      @counter = 0
      @start_time = 0
    end

    # This function will perform the required actions to traverse the Repo.
    # @example
    #   walk_repo = UpdateRepo::WalkRepo.new
    #   walk_repo.start
    def start
      configs, location = check_config
      show_header(configs, location)
      configs['location'].each do |loc|
        recurse_dir(loc, configs['exceptions'])
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
          dir.chomp!
          !exceptions.include?(dir) ? update_repo(dirpath) : skip_dir(dirpath)
        else
          recurse_dir(dirpath, exceptions)
        end
      end
    end

    # locate the configuration file and return this data.
    # Note that this will be re-written later to use my 'confoog' gem.
    # @return [hash] Hash containing all the configuration parameters.
    # @return [string] Location of the configuration file.
    def check_config
      # locate the configuration file.
      # first we check in this script location and if present then we ignore any
      # further files.
      dev_config = File.join '.', CONFIG_FILE
      user_config = File.join Gem.user_home, CONFIG_FILE

      if File.exist? dev_config
        # configuration exists in script directory so we ignore any others.
        return YAML.load_file(dev_config), File.expand_path(dev_config)
      elsif File.exist? user_config
        # configuration exists in user home directory so we use that.
        return YAML.load_file(user_config), File.expand_path(user_config)
      end
      # otherwise return error
      print 'Error : Cannot find configuration file'.red, user_config.red,
            'aborting'.red
      exit 1
    end

    # Display a simple header to the console
    # @param configs [hash] Configuration hash, used here to list exceptions.
    # @param location [string] location of config file.
    # @example
    #   show_header
    # @return []
    def show_header(configs, location)
      # print an informative header before starting
      print "\nGit Repo update utility (v", VERSION, ')',
            " \u00A9 Grant Ramsay <seapagan@gmail.com>\n"
      print "Using Configuration from #{location}\n"
      list_locations(configs)
      if configs['exceptions']
        print "\nExclusions:".underline, ' ',
              configs['exceptions'].join(', ').yellow, "\n"
      end
      # save the start time for later display in the footer...
      @start_time = Time.now
      print "\n" # blank line before processing starts
    end

    # print out a brief footer. This will be expanded later.
    # @return [void]
    def footer
      duration = Time.now - @start_time
      print "\nUpdates completed - #{@counter} repositories processed in ",
            "#{Time.at(duration).utc.strftime('%H:%M:%S')}\n\n".cyan
    end

    def list_locations(configs)
      print "\nRepo location(s):\n".underline
      configs['location'].each do |loc|
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
