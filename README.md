# update_repo [![Gem Version](https://badge.fury.io/rb/update_repo.svg)](https://badge.fury.io/rb/update_repo) [![Build Status](https://travis-ci.org/seapagan/update_repo.svg?branch=master)](https://travis-ci.org/seapagan/update_repo)

[![Coverage Status](https://coveralls.io/repos/seapagan/update_repo/badge.svg?branch=master&service=github)](https://coveralls.io/github/seapagan/update_repo?branch=master)
[![Code Climate](https://codeclimate.com/github/seapagan/update_repo/badges/gpa.svg)](https://codeclimate.com/github/seapagan/update_repo)
[![Inline docs](http://inch-ci.org/github/seapagan/update_repo.svg?branch=master)](http://inch-ci.org/github/seapagan/update_repo)
[![PullReview stats](https://www.pullreview.com/github/seapagan/update_repo/badges/master.svg?)](https://www.pullreview.com/github/seapagan/update_repo/reviews/master)

A Simple Gem to keep multiple locally-cloned Git Repositories up to date.

This is the conversion to a Gem of one of my standalone Ruby scripts. Still a work in progress but the required base functionality is there.
The script will simply run `git pull` on every local clone of a git repository that it finds under the specified directory or directories.

__Note:__ From version 0.9.0 onwards, the default mode of operation is non-verbose. If you wish the same output as previous versions then specify `--verbose` on the command line or `verbose: true` in the configuration file.

## Installation

#### Pre-requirements

It goes without saying that at the very least a working copy of both [`Git`][git] (version 1.8.5 or greater, the script will not run with an older version) and [`Ruby`][ruby] (version 1.9.3 and newer) need to be installed on your machine. Also, the script has currently only been tested under Linux, not windows.

Install this from the shell prompt as you would any other Ruby Gem

```
$ gem install update_repo
```

## Usage

#### Quick start
Create a [YAML][yaml]-formatted configuration file `.updaterepo` **in your home directory** that contains at least a 'location' tag pointing to the directory containing the git repositories you wish to have updated :
```yaml
---
location:
- /media/myuser/git-repos
- /data/RepoDir
```
This is the most basic example of a configuration file and there are other options that can be added to fine-tune the operation - see the description of configuration options below and the [Website][website] for more information.

This file should be located in the users home directory (`~/.updaterepo`).

Run the script :
```
$ update_repo
```

## Configuration
The below is a summary of the most common configuration options, see the [Website][website] for complete details and usage.
#### Configuration file
The configuration file defaults to `~/.updaterepo` and is a standard [YAML][yaml]-formatted text file. If this configuration file is not found, the script will terminate with an error.
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

`verbose:` - display the output of the git command for each repo, defaults to FALSE (optional)
```yaml
verbose: true
```

`quiet:` - no output at all, not even the header and footer, defaults to FALSE (optional)
```yaml
quiet: true
```

#### Command line switches
Options are not required. If none are specified then the program will read from the standard configuration file (~/.updaterepo) and automatically update the specified Repositories. Command line options will take preference over those specified in the configuration file. Again, see the [Website][website] for complete details and usage.

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
  -g, --log-local            Create the logfile in the current directory instead of in the users home
                             directory.
  -r, --dump-remote          Create a dump to screen or log listing all the git remote URLS found in
                             the specified directories.
  -V, --verbose              Display each repository and the git output to screen
  -q, --quiet                Run completely silent, with no output to the terminal (except fatal errors).
  -v, --version              Print version and exit
  -h, --help                 Show this message
```

## To-Do
Add functionality, not in any specific order :

- Either add an option 'variants' or similar to allow non-standard git pull commands (eg Ubuntu kernel), or update the 'exceptions' option to do same.
- Add command line option to specify an alternate config file.
- Add ability to specify a new directory (containing Git repos) to search from the command line, and optionally save this to the standard configuration.
- Add new repo from the command line that will be cloned to the default repo directory and then updated as usual. Extra flag added for "add only, clone later" for offline use.
- Add flag for 'default' repo directory (or another specific directory - if it does not already exist it will be created and added to the standard list) which will be used for new additions.
- Add option to only display a (text) tree of the discovered git repositories, not updating them.
- Add Import & Export functionality :
  * ability to export a text dump of each repo location and remote as a CSV file. `[DONE]`
  * re-import the above dump on a different machine or after reinstall. Modify the '--prune' command to apply to this function also, removing the required number of directory levels before importing.
- Add option to use alternative git command if required, either globally or on a case-by-case basis (see also comments on 'variants' above). Currently the script just uses a blanket `git pull` command on all repositories.
- Add option to specify a completely different directory for the log file other than the 2 current options of home dir and local dir
- Document configuration file format and options. `[IN PROGRESS]`

Internal Changes and refactoring :
- Add testing!
- Error checking and reporting for the git processes `[IN PROGRESS]`
- Improve error-checking and recovery while parsing the configuration file
  * Ignore and report invalid or missing directories
  * Add more failure cases, there may be more git errors than "fatal:" or "error:"
- Retry for connection issues etc (config setting).

## Development

### Developing for the Gem

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests (or simply `rake`). You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

Run `rake` to run the RSpec tests, which also runs `RuboCop`, `Reek` and `inch --pedantic` too.

### Developing for the Website

The source for the Gem’s website is also included in this repository. In fact, there are 2 main folders related to the website :

- [/web/](web/) folder - this is the SOURCE of the website, and all modifications should be performed here.
- [/docs/](docs/) folder - this is the GENERATED OUTPUT for the website, and this folder is served up directly and live to the web using GitHub Pages. Do not make any modifications to the files in this folder directly, your changes will be overwritten when the website is generated. Alway make changes in the /web/folder.

There are also a few support files to configure Node and Gulp which are used for the build process.

For full details on how to update the website properly, please see the [WEBSITE.md](WEBSITE.md) file in the root of this repository.

Any modifications that implement new functionality or user-facing API should also come with the relevant update to the website documenting the new options or modified functionality. Generally a Pull Request will not be accepted without the related additions to the website, however help can be given on that side if the process is unclear.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please note - This Gem currently aims to pass 100% on [RuboCop][rubocop], [Reek][reek] and [Inch-CI][inch] (on pedantic mode), so all pull requests should do likewise. Ask for guidance if needed.
Running `rake` will automatically test all 3 of those along with the RSpec tests.

## Versioning

This Gem aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations
of this scheme should be reported as bugs. Specifically, if a minor or patch
version is released that breaks backward compatibility, that version should be
immediately yanked and/or a new version should be immediately released that
restores compatibility. Breaking changes to the public API will only be
introduced with new major versions.

Of course, currently we have not even reached version 1, so leave off the version requirement completely. Expect any and all of the API and interface to change!

## License

The gem is available as open source under the terms of the [MIT License][mit].

[website]: http://updaterepo.seapagan.net
[git]: http://git-scm.com
[ruby]: http://www.ruby-lang.org
[yaml]:  http://yaml.org
[rubocop]: https://github.com/bbatsov/rubocop
[reek]: https://github.com/troessner/reek
[inch]: https://inch-ci.org
[semver]: http://semver.org/
[pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[confoog]: http://confoog.seapagan.net
[mit]: http://opensource.org/licenses/MIT

