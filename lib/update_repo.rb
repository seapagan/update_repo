require 'update_repo/version'
require 'yaml'
require 'colorize'

module UpdateRepo

  CONFIG_FILE = '.updatereporc'
  $counter = 0

  def recurse_dir(dirname, exceptions)
    Dir.foreach(dirname) do |dir|
      dirpath = dirname + '/' + dir
      if File.directory?(dirpath) && dir != '.' && dir != '..'
        gitpath = dirpath + '/.git'
        if File.exist?(gitpath) && File.directory?(gitpath)
          if !exceptions.include?(dir.chomp)
            update_repo(dirpath)
            $counter += 1
          else
            Dir.chdir(gitpath) do
              repo_url = `git config remote.origin.url`.chomp
              print "* Skipping #{dirpath}".yellow, " (#{repo_url})\n"
            end
          end
        else
          recurse_dir(dirpath, exceptions)
        end
      end
    end
  end

  def show_header(configs, location)
    # print an informative header before starting
    print "\nGit Repo update utility (v.0.1.0)".underline, " \u00A9 Grant Ramsay <seapagan@gmail.com>\n"
    puts "Using Configuration from #{location}"
    puts "\nRepo location(s):".underline
    configs['location'].each do |loc|
      print '-> ', loc.cyan, "\n"
    end
    if configs['exceptions']
      print "\nExclusions:".underline, ' ', configs['exceptions'].join(', ').yellow, "\n"
    end
    puts # blank line before processing starts
  end

  def update_repo(dirname)
    Dir.chdir(dirname) do
      repo_url = `git config remote.origin.url`.chomp
      print '* ', 'Checking ', dirname.green, " (#{repo_url})\n"
      print '  -> '
      system 'git pull'
    end
  end

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
    puts "Error : Cannot find configuration file '#{user_config}', aborting".red
    exit 1
  end
end
