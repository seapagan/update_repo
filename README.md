# update_repo [![Gem Version](https://badge.fury.io/rb/update_repo.svg)](https://badge.fury.io/rb/update_repo) [![Build Status](https://travis-ci.org/seapagan/update_repo.svg?branch=master)](https://travis-ci.org/seapagan/update_repo)

[![Dependency Status](https://gemnasium.com/seapagan/update_repo.svg)](https://gemnasium.com/seapagan/update_repo)
[![Coverage Status](https://coveralls.io/repos/seapagan/update_repo/badge.svg?branch=master&service=github)](https://coveralls.io/github/seapagan/update_repo?branch=master)
[![Code Climate](https://codeclimate.com/github/seapagan/update_repo/badges/gpa.svg)](https://codeclimate.com/github/seapagan/update_repo)
[![Inline docs](http://inch-ci.org/github/seapagan/update_repo.svg?branch=master)](http://inch-ci.org/github/seapagan/update_repo)
[![PullReview stats](https://www.pullreview.com/github/seapagan/update_repo/badges/master.svg?)](https://www.pullreview.com/github/seapagan/update_repo/reviews/master)

A Simple Gem to keep multiple locally-cloned Git Repositories up to date.

This is the conversion to a Gem of one of my standalone Ruby scripts. Still very much a work in progress but the required basic functionality is there.
The script will simply run `git pull` on every local clone of a git repository that it finds under the specified directory or directories.

## Installation

#### Pre-requirements

It goes without saying that at the very least a working copy of both [`Git`][git] and [`Ruby`][ruby] need to be installed on your machine. Also, the script has currently only been tested under Linux, not windows.

[git]: http://git-scm.com
[ruby]: http://www.ruby-lang.org

Install this from the shell prompt as you would any other Ruby Gem

```
 $ gem install update_repo
```

## Usage

#### Quick start
Create a [YAML](http://yaml.org/)-formatted configuration file `.updaterepo` **in your home directory** that contains at least a 'location' tag pointing to the directory containing the git repositories you wish to have updated :
```yaml
---
location:
- /media/myuser/git-repos
- /data/RepoDir
```
This is the most basic example of a configuration file and there are other options that can be added to fine-tune the operation - see the description of configuration options below.

This file should be located in the users home directory (`~/.updaterepo`).

Run the script :
```
$ update_repo
```

## Configuration
#### Configuration file
The configuration file defaults to `~/.updaterepo` and is a standard [YAML](http://yaml.org/)-formatted text file. If this configuration file is not found, the script will terminate with an error.  
The first line must contain the YAML frontmatter of 3 dashes (`---`). After that, the following sections can follow in any order. Only the `location:` section is compulsory, and that must contain at least one entry.

`location:` - at least one directory which contains the locally cloned repository(s) to update. There is no limit on how many directories can be listed :
```yaml
---
location:
- /media/myuser/git-repos
- /data/RepoDir
```

`exceptions:` - an (optional) list of repositories that will NOT be updated automatically. Use this for repositories that need special handling, or should only be manually updated. Note that the name specified is that of the __directory__ holding the repository (has the `.git` directory inside)
```yaml
exceptions:
- ubuntu-trusty
- update_repo
```

`log:` - Log all output to the file `./.updaterepo`, defaults to FALSE (optional)
```yaml
log: true
```

`timestamp:` - timestamp the output files instead of overwriting them, defaults to FALSE (optional)
```yaml
timestamp: true
```

#### Command line switches
Options are not required. If none are specified then the program will read from the standard configuration file (~/.updaterepo) and automatically update the specified Repositories.

Enter `update_repo --help` at the command prompt to get a list of available options :
```
Options:
  -c, --color, --no-color    Use colored output (default: true)
  -d, --dump                 Dump a list of Directories and Git URL's to STDOUT in CSV format
  -p, --prune=<i>            Number of directory levels to remove from the --dump output.
                             Only valid when --dump or -d specified (Default: 0)
  -l, --log                  Create a logfile of all program output to './update_repo.log'.
                             Any older logs will be overwritten.
  -t, --timestamp            Timestamp the logfile instead of overwriting. Does nothing unless the
                             --log option is also specified.
  -v, --version              Print version and exit
  -h, --help                 Show this message
```

## To-Do
Add functionality, not in any specific order :

- Either add an option 'variants' or similar to allow non-standard git pull commands (eg Ubuntu kernel), or update the 'exceptions' option to do same.
- Improve the stats / info at end-of-job :
  * errors or connection problems `[IN PROGRESS]`
  * _more..._
- Add command line options to override configuration, and even specify an alternate config file. Any options so specified will have precedence over settings specified in the configuration file.
- Add command line options for verbose or quiet, with same options in config file.
- Add ability to specify a new directory (containing Git repos) to search from the command line, and optionally save this to the standard configuration.
- Add new repo from the command line that will be cloned to the default repo directory and then updated as usual. Extra flag added for "add only, clone later" for offline use.
- Add flag for 'default' repo directory (or another specific directory - if it does not already exist it will be created and added to the standard list) which will be used for new additions.
- Add option to only display a (text) tree of the discovered git repositories, not updating them; Similar option to just dump a list of the remote git locations.
- Add Import & Export functionality :
  * ability to export a text dump of each repo location `[DONE]`
  * re-import the above dump on a different machine or after reinstall
- Add option to use alternative git command if required, either globally or on a case-by-case basis (see also comments on 'variants' above). Currently the script just uses a blanket `git pull` command on all repositories.
- Document configuration file format and options.

Internal Changes and refactoring :
- Add testing!
- Refactor all command-line handling into a separate class and file
- Error checking and reporting for the git processes `[IN PROGRESS]`
- Improve error-checking and recovery while parsing the configuration file
  * Ignore and report invalid or missing directories
  * Add more failure cases, not all git errors fail with "fatal:"
- Retry for connection issues etc (config setting).
- Fix functionality so that command line options will override those in the config file

[confoog]: http://confoog.seapagan.net

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests (or simply `rake`). You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

Run `rake` to run the RSpec tests, which also runs `RuboCop`, `Reek` and `inch --pedantic` too.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please note - This Gem currently aims to pass 100% on [RuboCop][rubocop], [Reek][reek] and [Inch-CI][inch] (on pedantic mode), so all pull requests should do likewise. Ask for guidance if needed.
Running `rake` will automatically test all 3 of those along with the RSpec tests. Note that Failures of Rubocop will cause the CI (Travis) to fail, however 'Reek' failures will not.

[rubocop]: https://github.com/bbatsov/rubocop
[reek]: https://github.com/troessner/reek
[inch]: https://inch-ci.org

## Versioning

This Gem aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations
of this scheme should be reported as bugs. Specifically, if a minor or patch
version is released that breaks backward compatibility, that version should be
immediately yanked and/or a new version should be immediately released that
restores compatibility. Breaking changes to the public API will only be
introduced with new major versions.

Of course, currently we have not even reached version 1, so leave off the version requirement completely. Expect any and all of the API and interface to change!

[semver]: http://semver.org/
[pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
