var gulp = require('gulp');
var sass = require('gulp-sass');
var browserSync = require('browser-sync');
var autoprefixer = require('gulp-autoprefixer');
var browserify = require('gulp-browserify');
var clean = require('gulp-clean');
var concat = require('gulp-concat');
var merge = require('merge-stream');
var newer = require('gulp-newer');
var imagemin = require('gulp-imagemin');
var injectPartials = require('gulp-inject-partials');
var minify = require('gulp-minify');
var cssmin = require('gulp-cssmin');
var rename = require('gulp-rename');
var htmlmin = require('gulp-htmlmin');
var htmlreplace = require('gulp-html-replace');
var mustache = require('gulp-mustache');
var log = require('fancy-log');
var c = require('ansi-colors');
var args = require('minimist')(process.argv.slice(2));
var noop = require('gulp-noop');

var SOURCEPATHS = {
  sassSource: 'sass/*.scss',
  sassPartials: 'sass/partials/*.scss',
  htmlSource: '*.html',
  htmlPartials: 'partials/*.html',
  jsSource: 'js/**',
  cssSource: 'css/**',
  imgSource: 'img/**',
  jsonSource: 'webdata.json'
};

var APPPATH = {
  root: '../docs/',
  css: '../docs/css',
  js: '../docs/js',
  fonts: '../docs/fonts',
  img: '../docs/img'
};

// determine if we want production mode (minified js/css/html) or not
var isProduction = false;
if (args.prod === true) {
  isProduction = true;
}

gulp.task('clean-all', function () {
  return gulp.src([APPPATH.root + '/*.html', APPPATH.css + '/*.css', APPPATH.js + '/*.js', APPPATH.fonts + '/*'], {read: false, force: true})
    .pipe(clean({force: true}));
});

gulp.task('sass', function () {
  var bootstrapCSS = gulp.src('./node_modules/bootstrap/dist/css/bootstrap.css');
  var sassFiles;
  var cssFiles = gulp.src([SOURCEPATHS.cssSource, './node_modules/@fortawesome/fontawesome-free/css/all.css', './node_modules/prismjs/themes/prism.css']);

  sassFiles = gulp.src(SOURCEPATHS.sassSource)
    .pipe(sass({outputStyle: 'expanded'}).on('error', sass.logError))
    .pipe(autoprefixer());
  return merge(cssFiles, bootstrapCSS, sassFiles)
    .pipe(concat('site.css'))
    .pipe(isProduction ? cssmin({keepSpecialComments: 0}) : noop())
    .pipe(isProduction ? rename({suffix: '.min'}) : noop())
    .pipe(gulp.dest(APPPATH.css));
});

gulp.task('scripts', function (done) {
  var fontawesomeJS = './node_modules/@fortawesome/fontawesome-free/js/all.js'
  var prismJS = './node_modules/prismjs/prism.js';
  var prismYAML = './node_modules/prismjs/components/prism-yaml.js';
  var prismWS = './node_modules/prismjs/plugins/normalize-whitespace/prism-normalize-whitespace.js';

  gulp.src([SOURCEPATHS.jsSource, fontawesomeJS, prismJS, prismYAML, prismWS])
    .pipe(concat('main.js'))
    .pipe(browserify())
    .pipe(isProduction ? minify({noSource: true}) : noop())
    .pipe(gulp.dest(APPPATH.js));
  done();
});

gulp.task('html', function () {
  return gulp.src(SOURCEPATHS.htmlSource)
    .pipe(injectPartials({
      removeTags: true
    }))
    .pipe(mustache(SOURCEPATHS.jsonSource))
    .pipe(isProduction ? htmlreplace({'css': 'css/site.min.css', 'js': 'js/main-min.js'}) : noop())
    .pipe(isProduction ? htmlmin({collapseWhitespace: true, removeComments: true}) : noop())
    .pipe(gulp.dest(APPPATH.root));
});

gulp.task('images', function () {
  return gulp.src(SOURCEPATHS.imgSource)
    .pipe(newer(APPPATH.img))
    .pipe(imagemin())
    .pipe(gulp.dest(APPPATH.img));
});

gulp.task('moveFonts', function (done) {
  gulp.src(['./node_modules/bootstrap/dist/fonts/**', './node_modules/@fortawesome/fontawesome-free/webfonts/**', './node_modules/font-awesome/fonts/**'])
    .pipe(gulp.dest(APPPATH.fonts));
  done();
});

gulp.task('serve', gulp.series(['sass', 'scripts'], function () {
  browserSync.init([APPPATH.css + '/*.css', APPPATH.root + '/*.html', APPPATH.js + '/*.js'], {
    server: {
      baseDir: APPPATH.root
    },
    open: false
  });
}));

gulp.task('output-env', async function () {
  return isProduction ? log(c.red.bold.underline('Running PRODUCTION environment')) : log(c.green.bold.underline('Running DEVELOPMENT environment'));
});

gulp.task('watch', gulp.series(['output-env', 'serve', 'clean-all', 'moveFonts', 'images', 'html'], function () {
  gulp.watch([SOURCEPATHS.sassSource, SOURCEPATHS.sassPartials, SOURCEPATHS.cssSource], ['sass']);
  gulp.watch([SOURCEPATHS.jsSource], ['scripts']);
  gulp.watch([SOURCEPATHS.imgSource], ['images']);
  gulp.watch([SOURCEPATHS.htmlSource, SOURCEPATHS.htmlPartials, SOURCEPATHS.jsonSource], ['html']);
}));

gulp.task('default', gulp.series(['watch']));

gulp.task('build', gulp.series(['output-env', 'clean-all', 'sass', 'scripts', 'moveFonts', 'images', 'html']));
