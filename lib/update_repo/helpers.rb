# Module 'Helers' containing assorted helper functions required elsewhere
module Helpers
  # will remove the first 'how_many' root levels from a directory path 'dir'..
  def trunc_dir(dir, how_many)
    # make sure we don't lose any root slash if '--prune' is NOT specified
    return dir if how_many == 0
    # convert to array then lose the first 'how_many' parts
    path_array = Pathname(dir).each_filename.to_a
    path_array = path_array.drop(how_many)
    # join it all back up again and return it
    File.join(path_array)
  end

  # true if we are dumping the file structure and git urls instead of updating.
  def dumping?
    param_set('dump')
  end

  # mark these as private simply so that 'reek' wont flag as utility function.
  private

  def gitdir?(dirpath)
    gitpath = dirpath + '/.git'
    File.exist?(gitpath) && File.directory?(gitpath)
  end

  def show_time(duration)
    time_taken = Time.at(duration).utc
    time_taken.strftime('%-H hours, %-M Minutes and %-S seconds.').cyan
  end
end