# update_repo [![Gem Version](https://badge.fury.io/rb/update_repo.svg)](https://badge.fury.io/rb/update_repo)

A Simple Gem to keep multiple cloned Git Repositories up to date.

This is the conversion to a Gem of one of my standalone Ruby scripts. Still very much work in progress, but functions as required.

## Usage

#### Pre-requirements

It goes without saying that at the very least a working copy of [Git][git] needs to be installed on your machine. Also, the script has only been tested under Linux, not windows.

[git]: http://git-scm.com

#### Quick start
Create a [YAML](http://yaml.org/)-formatted configuration file `.updatereporc` **in your home directory** that contains at least a 'location' tag pointing to the directory containing the git repositories you wish to have updated :
```yaml
---
location:
- /media/myuser/git-repos
- /data/RepoDir
```
This is the most basic example of a configuration file and there are other options that can be added to fine-tune the operation - see the description of configuration options below.

This file should be located in the users home directory (`~/.updatereporc`).

Run the script :
```
$ update_repo
```

## Configuration
#### Configuration file
To be added.

#### Command line switches
To be added.

## To-Do
Not in any specific order :

- Improve error-checking and recovery while parsing the configuration file (convert to using my '[Confoog][confoog]' gem for example)
- Either add an option 'variants' or similar to allow non-standard git pull commands (eg Ubuntu kernel), or update the 'exceptions' option to do same.
- Error checking and reporting for the git processes - retry for connection issues etc (config setting).
- Add extra (optional) stats / info at end-of-job :
    * number of repos updated
    * number of repos skipped
    * list of changed repos
    * errors or connection problems
    * _more..._
- Add command line options to override configuration, and even specify an alternate config file. Any options so specified will have precedence over settings specified in the configuration file.
- Add command line options for verbose or quiet, with same options in config file.
- Add ability to specify a new directory (containing Git repos) to search from the command line, and optionally save this to the standard configuration.
- Add new repo from the command line that will be cloned to the default repo directory and then updated as usual. Extra flag added for "add only, clone later" for offline use.
- Add flag for 'default' repo directory (or another specific directory - if it does not already exist it will be created and added to the standard list) which will be used for new additions.
- Option to save log file for each run.
- Add option to only display a (text) tree of the discovered git repositories, not updating them; Similar option to just dump a list of the remote git locations.
- Document configuration file format and options.
- Add testing!

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

<del>Please note - This Gem currently aims to pass 100% on [RuboCop][rubocop], [Reek][reek] and [Inch-CI][inch] (on pedantic mode), so all pull requests should do likewise. Ask for guidance if needed.
Running `rake` will automatically test all 3 of those along with the RSpec tests. Note that Failures of Rubocop will cause the CI (Travis) to fail, however 'Reek' failures will not.</del>  
This is still currently a messy conversion to Gem from a standalone script, so the RSpec tests are non-existent and it will fail all [RuboCop][rubocop], [Reek][reek] and [Inch-CI][inch]. This will be quickly fixed though. Once that is done this message will be removed and the above comment reinstated.

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
