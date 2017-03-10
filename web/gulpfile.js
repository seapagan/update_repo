var gulp = require('gulp');
var sass = require('gulp-sass');
var browserSync =  require('browser-sync');
var reload = browserSync.reload;
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
var gutil = require('gulp-util');
var htmlreplace = require('gulp-html-replace');
var mustache = require('gulp-mustache');

var SOURCEPATHS = {
  sassSource   : 'sass/*.scss',
  htmlSource   : '*.html',
  htmlPartials : 'partials/*.html',
  jsSource     : 'js/**',
  cssSource    : 'css/**',
  imgSource    : 'img/**'
};

var APPPATH = {
  root  : '../docs/',
  css   : '../docs/css',
  js    : '../docs/js',
  fonts : '../docs/fonts',
  img   : '../docs/img'
};

// determine if we want production mode (minified js/css/html) or not
var isProduction = false;
if(gutil.env.prod === true) {
  isProduction = true;
}

gulp.task('clean-html', function() {
  return gulp.src(APPPATH.root + '/*.html', {read: false, force: true})
    .pipe(clean({force: true}));
});

gulp.task('clean-css', function() {
  return gulp.src(APPPATH.css + '/*.css', {read: false, force: true})
    .pipe(clean({force: true}));
});

gulp.task('clean-scripts', function() {
  return gulp.src(APPPATH.js + '/*.js', {read: false, force: true })
      .pipe(clean({force: true}));
});

gulp.task('sass', function() {
  var bootstrapCSS = gulp.src('./node_modules/bootstrap/dist/css/bootstrap.css');
  var sassFiles;
  var cssFiles = gulp.src([SOURCEPATHS.cssSource, './node_modules/font-awesome/css/font-awesome.css', './node_modules/prismjs/themes/prism.css']);

  sassFiles = gulp.src(SOURCEPATHS.sassSource)
    .pipe(sass({outputStyle: 'expanded'}).on('error', sass.logError))
    .pipe(autoprefixer());
    return merge(cssFiles, bootstrapCSS, sassFiles)
      .pipe(concat('site.css'))
      .pipe(isProduction ? cssmin({keepSpecialComments : 0}) : gutil.noop())
      .pipe(isProduction ? rename({suffix: '.min'}) : gutil.noop())
      .pipe(gulp.dest(APPPATH.css));
});

gulp.task('scripts', function() {
  var prismJS = './node_modules/prismjs/prism.js';
  var prismYAML = './node_modules/prismjs/components/prism-yaml.js';
  var prismWS =  './node_modules/prismjs/plugins/normalize-whitespace/prism-normalize-whitespace.js';

  gulp.src([SOURCEPATHS.jsSource, prismJS, prismYAML, prismWS])
    .pipe(concat('main.js'))
    .pipe(browserify())
    .pipe(isProduction ? minify({noSource: true}) : gutil.noop())
    .pipe(gulp.dest(APPPATH.js));
});

gulp.task('html', function() {
  return gulp.src(SOURCEPATHS.htmlSource)
    .pipe(injectPartials({
      removeTags : true
    }))
    .pipe(mustache('webdata.json'))
    .pipe(isProduction ? htmlreplace({'css': 'css/site.min.css', 'js': 'js/main-min.js'}) : gutil.noop())
    .pipe(isProduction ? htmlmin({collapseWhitespace: true, removeComments: true}) : gutil.noop())
    .pipe(gulp.dest(APPPATH.root));
});

gulp.task('images', function() {
  return gulp.src(SOURCEPATHS.imgSource)
    .pipe(newer(APPPATH.img))
    .pipe(imagemin())
    .pipe(gulp.dest(APPPATH.img));
});

gulp.task('moveFonts', function() {
  gulp.src(['./node_modules/bootstrap/dist/fonts/**', './node_modules/font-awesome/fonts/**'])
    .pipe(gulp.dest(APPPATH.fonts));
});

gulp.task('serve', ['sass', 'scripts'], function() {
  browserSync.init([APPPATH.css + '/*.css', APPPATH.root + '/*.html', APPPATH.js + '/*.js'], {
    server: {
      baseDir : APPPATH.root
    },
    open: false
  })
});

gulp.task('output-env', function() {
  isProduction ? gutil.log(gutil.colors.red.bold.underline("Running PRODUCTION environment")) : gutil.log(gutil.colors.green.bold.underline("Running DEVELOPMENT environment"))
});

gulp.task('watch', ['output-env', 'serve', 'clean-html', 'clean-scripts', 'clean-css', 'moveFonts', 'images', 'html'], function() {
  gulp.watch([SOURCEPATHS.sassSource, SOURCEPATHS.cssSource], ['sass']);
  gulp.watch([SOURCEPATHS.jsSource], ['scripts']);
  gulp.watch([SOURCEPATHS.imgSource], ['images']);
  gulp.watch([SOURCEPATHS.htmlSource, SOURCEPATHS.htmlPartials], ['html']);
});

gulp.task('default', ['watch']);

gulp.task('build', ['output-env', 'sass', 'scripts', 'clean-html', 'clean-scripts', 'clean-css', 'moveFonts', 'images', 'html']);
