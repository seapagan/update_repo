## Updating the Website.

The source code for the [website][website] is also included in this repository under the [/web/](web/) folder. There also exists a [/docs/](docs/) folder which contains the actual generated website itself and is directly served up to the web by GitHub from this folder.

Any modifications to the website must **always** be done in the [/web/](web/) folder only. The build process (see below) will regenerate the files in the [/docs/](docs/) folder automatically.

### Setting up the build environment.
We are using [NodeJS][node] and [Gulp][gulp] to streamline the build process for the website, with the following additional libraries :

- [Sass][sass] for the style sheets, however we use the [SCSS][scss] syntax over vanilla Sass in all the code.
- [Bootstrap][bootstrap] is used for layout and menus.
- [Font Awesome][fontawesome] provides excellent scalable icons and glyphs.
- [PrismJS][prism] is an excellent code hilighter, used when describing code and configuration file layout.

All the above dependencies are automatically pulled in using the Gulp task and updated using `npm`.

Primary development is carried out on a Linux machine, but all the above can be succesfully installed and used on Windows or Mac systems too.

#### Install Node and Gulp.
Blah.

#### Install the dependencies.
More Blah.


[website]: http://updaterepo.seapagan.net
[node]: http://nodejs.org
[gulp]: http://gulpjs.com
[sass]: http://sass-lang.com
[scss]: http://sass-lang.com/documentation/file.SCSS_FOR_SASS_USERS.html
[bootstrap]: http://getbootstrap.com
[fontawesome]: http://fontawesome.io
[prism]: http://prismjs.com
