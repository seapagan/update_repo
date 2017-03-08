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

var SOURCEPATHS = {
  sassSource   : 'web/sass/*.scss',
  htmlSource   : 'web/*.html',
  htmlPartials : 'web/partials/*.html',
  jsSource     : 'web/js/**',
  cssSource    : 'web/css/**',
  imgSource    : 'web/img/**'
};

var APPPATH = {
  root  : 'docs/',
  css   : 'docs/css',
  js    : 'docs/js',
  fonts : 'docs/fonts',
  img   : 'docs/img'
};

gulp.task('clean-html', function() {
  return gulp.src(APPPATH.root + '/*.html', {read: false, force: true})
    .pipe(clean());
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
      .pipe(gulp.dest(APPPATH.css));
});

gulp.task('scripts', function() {
  var prismJS = './node_modules/prismjs/prism.js';
  var prismYAML = './node_modules/prismjs/components/prism-yaml.js';
  var prismWS =  './node_modules/prismjs/plugins/normalize-whitespace/prism-normalize-whitespace.js';

  gulp.src([SOURCEPATHS.jsSource, prismJS, prismYAML, prismWS])
    .pipe(concat('main.js'))
    .pipe(browserify())
    .pipe(gulp.dest(APPPATH.js));
});

gulp.task('html', function() {
  return gulp.src(SOURCEPATHS.htmlSource)
    .pipe(injectPartials({
      removeTags : true
    }))
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

// Production Tasks
gulp.task('compress-js', function() {
  var prismJS = './node_modules/prismjs/prism.js';
  var prismYAML = './node_modules/prismjs/components/prism-yaml.js';
  var prismWS =  './node_modules/prismjs/plugins/normalize-whitespace/prism-normalize-whitespace.js';

  gulp.src([SOURCEPATHS.jsSource, prismJS, prismYAML, prismWS])
    .pipe(concat('main.js'))
    .pipe(browserify())
    .pipe(minify())
    .pipe(gulp.dest(APPPATH.js));
});

gulp.task('compress-css', function() {
  var bootstrapCSS = gulp.src('./node_modules/bootstrap/dist/css/bootstrap.css');
  var sassFiles;
  var cssFiles = gulp.src([SOURCEPATHS.cssSource, './node_modules/font-awesome/css/font-awesome.css', './node_modules/prismjs/themes/prism.css']);

  sassFiles = gulp.src(SOURCEPATHS.sassSource)
    .pipe(sass({outputStyle: 'expanded'}).on('error', sass.logError))
    .pipe(autoprefixer());
    return merge(cssFiles, bootstrapCSS, sassFiles)
      .pipe(concat('site.css'))
      .pipe(cssmin())
      .pipe(rename({suffix: '.min'}))
      .pipe(gulp.dest(APPPATH.css));
});
// End of Production Tasks.

gulp.task('watch', ['serve', 'clean-html', 'moveFonts', 'images', 'html'], function() {
  gulp.watch([SOURCEPATHS.sassSource, SOURCEPATHS.cssSource], ['sass']);
  gulp.watch([SOURCEPATHS.jsSource], ['scripts']);
  gulp.watch([SOURCEPATHS.imgSource], ['images']);
  gulp.watch([SOURCEPATHS.htmlSource, SOURCEPATHS.htmlPartials], ['html']);
});

gulp.task('default', ['watch']);
