require 'update_repo/version'
require 'update_repo/helpers'
require 'confoog'
require 'trollop'
require 'yaml'

# this class will encapsulate the command line fucntionality and processing
# as well as reading from the config file. It will also merge the 2 sources
# into the final definitive option hash.
module UpdateRepo
  # This class takes care of reading and parsing the command line and conf file
  class CmdConfig
    include Helpers

    def initialize
      # read the options from Trollop and store in temp variable.
      # we do it this way around otherwise if configuration file is missing it
      # gives the error messages even on '--help' and '--version'
      temp_opt = set_options
      @conf = Confoog::Settings.new(filename: CONFIG_FILE,
                                    prefix: 'update_repo',
                                    autoload: true, autosave: false)
      @conf['cmd'] = temp_opt
      check_params
      config_error unless @conf.status[:errors] == Status::INFO_FILE_LOADED
    end

    # return the configuration hash variable
    # @param [none]
    # @return [Class] Returns the base 'confoog' class to the caller.
    # @example
    #   @config = @cmd.getconfig
    def getconfig
      @conf
    end

    # This will return the 'true' version of a command, taking into account
    # both command line (given preference) and the configuration file.
    # @param command [symbol] The symbol of the defined command
    # @return [various] Returns the true value of the comamnd symbol
    def true_cmd(command)
      cmd_given = @conf['cmd'][(command.to_s + '_given').to_sym]
      cmd_line = @conf['cmd'][command.to_sym]

      if cmd_given
        # if we specify something on the cmd line, that takes precedence
        cmd_line
      elsif !@conf[command.to_s].nil?
        # if we have a value in the config file we use that.
        @conf[command.to_s]
      else
        # this will catch any 'default' values in the cmd setup.
        cmd_line
      end
    end

    # rubocop:disable Metrics/LineLength
    # make sure the parameter combinations are valid, terminating otherwise.
    # @param [none]
    # @return [void]
    def check_params
      return unless true_cmd(:dump)
      # if  true_cmd(:import)
      Trollop.die 'You cannot use --dump AND --import'.red if true_cmd(:import)
      # end
      # if true_cmd(:dump_remote)
      Trollop.die 'You cannot use --dump AND --dump-remote'.red if true_cmd(:dump_remote)
      # end
    end
    # rubocop:enable  Metrics/LineLength

    private

    # terminate if we cannot load the configuration file for any reason.
    # @param [none]
    # @return [integer] exit code 1
    def config_error
      if @conf.status[:errors] == Status::ERR_CANT_LOAD
        print_log 'Note that the the default configuration file was '.red,
                  "changed to ~/#{CONFIG_FILE} from v0.4.0 onwards\n\n".red
      end
      exit 1
    end

    # Set up the Trollop options and banner
    # @param [none]
    # @return [void]
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
        # opt :import, "Import a previous dump of directories and Git repository URL's,\n(created using --dump) then proceed to clone them locally.", default: false
        opt :log, "Create a logfile of all program output to './update_repo.log'. Any older logs will be overwritten.", default: false
        opt :timestamp, 'Timestamp the logfile instead of overwriting. Does nothing unless the --log option is also specified.', default: false
        opt :dump_remote, 'Create a dump to screen or log listing all the git remote URLS found in the specified directories.', default: false, short: 'r'
        opt :dump_tree, 'Create a dump to screen or log listing all subdirectories found below the specified locations in tree format.', default: false, short: 'u'
        # opt :quiet, 'Only minimal output to the terminal', default: false
        # opt :silent, 'Completely silent, no output to terminal at all.', default: false
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable  Metrics/LineLength
  end
end
