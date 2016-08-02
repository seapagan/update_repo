# Module 'Helpers' containing assorted helper functions required elsewhere
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

  # this function will simply pass the given string to 'print', and also
  # log to file if that is specified.
  def print_log(*string)
    # log to screen regardless
    print(*string)
    # log to file if that has been enabled
    @logfile.write(string.join('').gsub(/\e\[(\d+)(;\d+)*m/, '')) if cmd('log')
  end

  # mark these as private simply so that 'reek' wont flag as utility function.
  private

  def gitdir?(dirpath)
    gitpath = dirpath + '/.git'
    File.exist?(gitpath) && File.directory?(gitpath)
  end

  def show_time(duration)
    time_taken = Time.at(duration).utc
    time_taken.strftime('%-H hours, %-M Minutes and %-S seconds')
  end
end
