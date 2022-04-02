# Updating the Website

The source code for the [website][website] is also included in this repository under the [/web/](web/) folder. There also exists a [/docs/](docs/) folder which contains the actual generated website itself and is directly served up to the web by GitHub from this folder.

Any modifications to the website must **always** be done in the [/web/](web/) folder only. The build process (see below) will regenerate the files in the [/docs/](docs/) folder automatically.

## Setting up the build environment

We are using [NodeJS][node] and [Webpack][webpack] to streamline the build process for the website, with the following additional libraries :

- We use PostCSS as a replacement for SASS to take care of the CSS
- [Fomantic-UI][fomanticui] is used for layout and menus.
- [Font Awesome][fontawesome] provides excellent scalable icons and glyphs.
- [PrismJS][prism] is an excellent code highlighter, used when describing code and configuration file layout.
- The [Mustache][mustache] template language is used in a few places to automate repetitive HTML coding (For example in the command line parameters)

All the above dependencies are automatically pulled in using `npm`.

Primary development was originally carried out on a Linux machine, but all the above can be successfully installed and used on Windows or Mac systems too. Infact I now use [Windows Subsystem for Linux][wsl] and [Visual Studio Code][vscode] for development - which I can really recommend by the way.

### Install Node and Webpack

Install the latest LTS version of [Node][node] by following the instructions on their website depending on your operating system. Note that you should use Node version 12.x or more, lower versions will not work properly with some dependencies. I recommend that you use a Node Version Manager if you want multiple node versions installed - [NVM][nvm] is good for Linux and Mac (and also great on [WSL][wsl]) while [NVM-Windows][nvm-windows] is great for those on windows.
Development is currently carried out using Node version 16.14.2 so it may be worth installing that version.
When you have NVM installed under Linux and the above version of Node, you can then change to the [/web/](web/) directory and simply type:

```bash
nvm use
```

This will switch to locally using the same version of Node that is used for development here thanks to the `.nvmrc` file found in this directory. If you are using a different version however, just select that version instead.

Once you have Node up and running, switch to the [/web/](web/) folder and install the project dependencies:

```bash
npm install
```

This will install webpack and all the bits and bobs it needs locally.

### Run the Webpack watcher

The Webpack task will take care of generating the website in the [/docs/](docs/) folder. Before starting, run the following from the [/web/](web/) folder, in a DIFFERENT console to that you will work in. This runs a continuous watch process and automatically refreshes your browser after each change:

```bash
npm run dev
```

Now, when you change any HTML, CSS or JavaScript those changes will be copied over to the correct place. CSS and partials will be compiled and inserted into the HTML code, and the web browser will automatically refresh for you - this can be accessed from `http://localhost:3000`.

When all is good, we cen generate a production-ready website by running the following from the `master` branch:

```bash
npm run build
```

This will then present a minimized version (along with a CNAME file) suitable for running under Github Pages. Simply pushing this to Github will update the Website automatically.

### **There is still some work to do on the website, mainly getting the Mustache scripts working again.**

[website]: http://updaterepo.seapagan.net
[node]: http://nodejs.org
[webpack]: https://webpack.js.org/
[mustache]: https://mustache.github.io/
[fomanticui]: https://fomantic-ui.com/
[fontawesome]: http://fontawesome.io
[prism]: http://prismjs.com
[nvm]: http://github.com/creationix/nvm
[nvm-windows]: https://github.com/coreybutler/nvm-windows
[wsl]: https://docs.microsoft.com/en-us/windows/wsl/about
[vscode]: https://code.visualstudio.com/
