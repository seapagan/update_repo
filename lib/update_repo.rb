require 'update_repo/version'
require 'update_repo/helpers'
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
      @metrics = { count: 0, skipped: 0, failed: 0, updated: 0, start_time: 0 }
      # read the options from Trollop and store in temp variable.
      # we do it this way around otherwise if configuration file is missing it
      # gives the error messages even on '--help' and '--version'
      temp_opt = set_options
      # @config - Class. Reads the configuration from a file in YAML format and
      # allows easy access to the configuration data
      @config = Confoog::Settings.new(filename: CONFIG_FILE,
                                      prefix: 'update_repo',
                                      autoload: true,
                                      autosave: false)
      # store the command line variables in a configuration variable
      @config['cmd'] = temp_opt
      config_error unless @config.status[:errors] == Status::INFO_FILE_LOADED
    end

    # This function will perform the required actions to traverse the Repo.
    # @example
    #   walk_repo = UpdateRepo::WalkRepo.new
    #   walk_repo.start
    def start
      String.disable_colorization = true unless param_set('color')
      no_import_export if dumping? && importing?
      if importing?
        Trollop.die "Sorry 'Import' functionality is not implemented yet".red
      else
        show_header
        @config['location'].each do |loc|
          recurse_dir(loc)
        end
      end
      # print out an informative footer...
      footer
    end

    private

    # Determine options from the command line and configuration file. Command
    # line takes precedence
    def param_set(option)
      @config['cmd'][option.to_sym] || @config[option]
    end

    def config_error
      if @config.status[:errors] == Status::ERR_CANT_LOAD
        print 'Note that the the default configuration file was '.red,
              "changed to ~/#{CONFIG_FILE} from v0.4.0 onwards\n\n".red
      end
      exit 1
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/LineLength
    def set_options
      Trollop.options do
        version "update_repo version #{VERSION} (C)2016 G. Ramsay\n"
        banner <<-EOS

Keep multiple local Git-Cloned Repositories up to date with one command.

Usage:
      update_repo [options]

Options are not required. If none are specified then the program will read from
the standard configuration file (~/#{CONFIG_FILE}) and automatically update the
specified Repositories.

Options:
EOS
        opt :color, 'Use colored output', default: true
        opt :dump, 'Dump a list of Directories and Git URL\'s to STDOUT in CSV format', default: false
        opt :prune, "Number of directory levels to remove from the --dump output.\nOnly valid when --dump or -d specified", default: 0
        opt :import, "Import a previous dump of directories and Git repository URL's,\n(created using --dump) then proceed to clone them locally.", default: false
        # opt :quiet, 'Only minimal output to the terminal', default: false
        # opt :silent, 'Completely silent, no output to terminal at all.',
        #    default: false
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable  Metrics/LineLength

    # take each directory contained in the Repo directory, if it is detected as
    # a Git repository then update it (or as directed by command line)
    # @param dirname [string] Contains the directory to search for Git repos.
    def recurse_dir(dirname)
      Dir.chdir(dirname) do
        Dir['**/'].each do |dir|
          next unless gitdir?(dir)
          if dumping?
            dump_repo(File.join(dirname, dir))
          elsif importing?
            # placeholder
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
      !@config['exceptions'].include?(File.basename(dir))
    end

    # Display a simple header to the console
    # @example
    #   show_header
    # @return [void]
    def show_header
      # print an informative header before starting
      # unless we are dumping the repo information
      return if dumping?
      print "\nGit Repo update utility (v", VERSION, ')',
            " \u00A9 Grant Ramsay <seapagan@gmail.com>\n"
      print "Using Configuration from '#{@config.config_path}'\n"
      print "Command line is : #{@config['cmd']}\n"
      # list out the locations that will be searched
      list_locations
      # list any exceptions that we have from the config file
      list_exceptions
      # save the start time for later display in the footer...
      @metrics[:start_time] = Time.now
      print "\n" # blank line before processing starts
    end

    # print out a brief footer. This will be expanded later.
    # @return [void]
    def footer
      # no footer if we are dumping the repo information
      return if dumping?
      duration = Time.now - @metrics[:start_time]
      print "\nUpdates completed : ", @metrics[:count].to_s.green,
            ' repositories processed'.green
      summary(@metrics[:updated], 'cyan', 'updated')
      summary(@metrics[:skipped], 'yellow', 'skipped')
      summary(@metrics[:failed], 'red', 'failed')
      print ' in ', show_time(duration).cyan, "\n\n"
    end

    def list_exceptions
      exceptions = @config['exceptions']
      if exceptions
        print "\nExclusions:".underline, ' ',
              exceptions.join(', ').yellow, "\n"
      end
    end

    def list_locations
      print "\nRepo location(s):\n".underline
      @config['location'].each do |loc|
        print '-> ', loc.cyan, "\n"
      end
    end

    def skip_repo(dirpath)
      Dir.chdir(dirpath.chomp!('/')) do
        repo_url = `git config remote.origin.url`.chomp
        print '* Skipping ', Dir.pwd.yellow, " (#{repo_url})\n"
        @metrics[:skipped] += 1
      end
    end

    def update_repo(dirname)
      Dir.chdir(dirname.chomp!('/')) do
        repo_url = `git config remote.origin.url`.chomp
        do_update(repo_url)
        @metrics[:count] += 1
      end
    end

    def do_update(repo_url)
      print '* Checking ', Dir.pwd.green, " (#{repo_url})\n"
      Open3.popen3('git pull') do |_stdin, stdout, stderr, thread|
        do_threads(stdout, stderr)
        thread.join
      end
    end

    def do_threads(stdout, stderr)
      { out: stdout, err: stderr }.each do |key, stream|
        Thread.new do
          while (line = stream.gets)
            if key == :err && line =~ /^fatal:/
              print '   ', line.red
              @metrics[:failed] += 1
            else
              print '   ', line.cyan
              # @metrics[:updated] += 1 if line =~ /files?\schanged/
              @metrics[:updated] += 1 if line =~ /^From\shttps?:\/\//
            end
          end
        end
      end
    end

    def dump_repo(dir)
      Dir.chdir(dir.chomp!('/')) do
        repo_url = `git config remote.origin.url`.chomp
        print "#{trunc_dir(dir, @config['cmd'][:prune])},#{repo_url}\n"
      end
    end
  end
end
