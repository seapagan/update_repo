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
      config_error unless @conf.status[:errors] == Status::INFO_FILE_LOADED
    end

    # return the configuration hash variable
    def getconfig
      @conf
    end

    # This will return the 'true' version of a command, taking into account
    # both command line (given preference) and the configuration file.
    # parameter is a :symbol
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

    # make sure the parameter combinations are valid
    def check_params
      if param_set('dumping') && param_set('importing')
        Trollop.die 'Sorry, you cannot specify both --dump and --import '.red
      end
    end

    # Determine options from the command line and configuration file. Command
    # line takes precedence
    def param_set(option)
      @conf['cmd'][option.to_sym] || @conf[option]
    end

    private

    def config_error
      if @conf.status[:errors] == Status::ERR_CANT_LOAD
        print_log 'Note that the the default configuration file was '.red,
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
        # opt :import, "Import a previous dump of directories and Git repository URL's,\n(created using --dump) then proceed to clone them locally.", default: false
        opt :log, "Create a logfile of all program output to './update_repo.log'. Any older logs will be overwritten.", default: false
        opt :timestamp, 'Timestamp the logfile instead of overwriting. Does nothing unless the --log option is also specified.', default: false
        # opt :quiet, 'Only minimal output to the terminal', default: false
        # opt :silent, 'Completely silent, no output to terminal at all.', default: false
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable  Metrics/LineLength
  end
end
