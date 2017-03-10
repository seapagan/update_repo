## Updating the Website.

The source code for the [website][website] is also included in this repository under the [/web/](web/) folder. There also exists a [/docs/](docs/) folder which contains the actual generated website itself and is directly served up to the web by GitHub from this folder.

Any modifications to the website must **always** be done in the [/web/](web/) folder only. The build process (see below) will regenerate the files in the [/docs/](docs/) folder automatically.

### Setting up the build environment.
We are using [NodeJS][node] and [Gulp][gulp] to streamline the build process for the website, with the following additional libraries :

- [Sass][sass] for the style sheets, however we use the [SCSS][scss] syntax over vanilla Sass in all the code.
- [Bootstrap][bootstrap] is used for layout and menus.
- [Font Awesome][fontawesome] provides excellent scalable icons and glyphs.
- [PrismJS][prism] is an excellent code hilighter, used when describing code and configuration file layout.
- The [Mustache][mustache] template language is used in a few places to automate repetative HTML coding (For example in the comand line parameters)


All the above dependencies are automatically pulled in using the Gulp task and updated using `npm`.

Primary development is carried out on a Linux machine, but all the above can be succesfully installed and used on Windows or Mac systems too.

#### Install Node and Gulp.
Install the latest 6.x.x LTS version of [Node][node] by following the instructions on their website depending on your operating system. Note that Node version 7.x will not work properly with some of Gulp's dependencies so please use the LTS Version 6. I recommend that you use a Node Version Manager if you want multiple node versions installed - [NVM][nvm] is good for Linux and Mac while [NVM-Windows][nvm-windows] is great for those on windows.
Development is currently carried out using Node version 6.10.0 so it may be worth installing that version.
When you have NVM installed under linux and the above version of Node, you can then change to the /web/ directory and simply type:
```
$ nvm use
```
This will switch to locally using the same version of Node that is used for development here thanks to the `.nvmrc` file found in this directory. If you are using a different version however, just select that version instead.

Once you have Node up and running, install [Gulp][gulp]:

```
$ npm install -g gulp
```
This will install Gulp globally, you may need to prefix this with the `sudo` command depending on how your machine is configured.
#### Install the dependencies.
This is really simple once Node and Gulp are installed. Simply switch to the [/web/](web/) folder in uour local checkout and type:
```
$ npm install
```
This will download and install all the required project dependencies and cache them locally, it may take some time.

#### Run the Gulp watcher.
The Gulp task will take care of generating the website in the [/docs/](docs/) folder. Before starting, run the following from the [/web/](web/) folder, in a DIFFERENT console to that you will work in. This runs a continuous watch process:
```
$ gulp
```
Now, when you change any HTML, CSS or JavaScript those changes will be copied over to the correct place. SCSS will be compiled into CSS and partials inserted into the HTML code.

[website]: http://updaterepo.seapagan.net
[node]: http://nodejs.org
[gulp]: http://gulpjs.com
[sass]: http://sass-lang.com
[scss]: http://sass-lang.com/documentation/file.SCSS_FOR_SASS_USERS.html
[mustache]: https://mustache.github.io/
[bootstrap]: http://getbootstrap.com
[fontawesome]: http://fontawesome.io
[prism]: http://prismjs.com
[nvm]: http://github.com/creationix/nvm
[nvm-windows]: https://github.com/coreybutler/nvm-windows
