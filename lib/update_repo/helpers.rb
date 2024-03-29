# frozen_string_literal: true

require 'resolv'

# Module 'Helpers' containing assorted helper functions required elsewhere
# ignore :reek:UtilityFunction for this Module
module Helpers
  # will remove the FIRST 'how_many' root levels from a directory path 'dir'..
  # @param dir [string] Path to be truncated
  # @param how_many [integer] How many levels to be dropped from path.
  # @return [string] the properly truncated path
  def trunc_dir(dir, how_many)
    # make sure we don't lose any root slash if '--prune' is NOT specified
    return dir if how_many.zero?

    # convert to array then lose the first 'how_many' parts
    path_array = Pathname(dir).each_filename.to_a
    path_array = path_array.drop(how_many)
    # join it all back up again and return it
    File.join(path_array)
  end

  # mark these as private simply so that 'reek' wont flag as utility function.
  # private

  # helper function to check if passed path is a Git Repository by checking for
  # the existence of a '.git' directory
  # @param dirpath [string] Path to be checked
  # @return [Boolean] True if path contains a Git repo
  def gitdir?(dirpath)
    gitpath = "#{dirpath}/.git"
    File.exist?(gitpath) && File.directory?(gitpath)
  end

  # Show a pretty-print version of the passed duration object
  # @param duration [integer] Time to be converted
  # @return [String] Pretty representation of the passed time.
  def show_time(duration)
    time_taken = Time.at(duration).utc
    time_taken.strftime('%-H hours, %-M Minutes and %-S seconds')
  end

  # helper function to call the Logger class output method.
  # @param *string [Array] Array of strings to be passed to the 'print' fn
  # @return [*string] Output of the Logger
  def print_log(*string)
    @log.output(*string)
  end

  # Cross-platform way of finding an executable in the $PATH.
  # From : http://stackoverflow.com/a/5471032/6641755
  #
  #   which('ruby') #=> /usr/bin/ruby
  # @param cmd [string] command to search for
  # @return [string] Location of the command or nil if not found
  def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end
    # return nil
  end

  # only one of our metrics requires pluralization, the :warning metric.
  # Take care of this in the function below.
  # @param num [integer] The number of items
  # @param item [string] The metric to be pluralized if needed
  # @return [string] Pluralized count and string
  def pluralize(num, item)
    if item == :warning && num != 1
      "#{num} Warnings"
    else
      "#{num} #{item.capitalize}"
    end
  end

  # check for a working internet connection, return true or false.
  # @param cmd [hash] current cmd settings hash.
  # @return [boolean] True if working Internet connection, False otherwise.
  def internet?(cmd)
    return true if cmd[:noinetchk]

    dns_resolver = Resolv::DNS.new
    begin
      dns_resolver.getaddress('icann.org')
      true
    rescue Resolv::ResolvError => _e
      print "\nThere appears to be no internet access on this computer, ".red,
            "the script cannot continue.\n\n".red
      false
    end
  end
end
