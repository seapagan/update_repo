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

gulp.task('clean-scripts', function() {
  return gulp.src(APPPATH.js + '/*.js', {read: false, force: true})
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

gulp.task('scripts', ['clean-scripts'], function() {
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

// gulp.task('copy', ['clean-html'], function() {
//   gulp.src(SOURCEPATHS.htmlSource)
//     .pipe(gulp.dest(APPPATH.root));
// });

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

gulp.task('serve', ['sass'], function() {
  browserSync.init([APPPATH.css + '/*.css', APPPATH.root + '/*.html', APPPATH.js + '/*.js'], {
    server: {
      baseDir : APPPATH.root
    },
    open: false
  })
});

gulp.task('watch', ['serve', 'sass', 'clean-html', 'clean-scripts', 'scripts', 'moveFonts', 'images', 'html'], function() {
  gulp.watch([SOURCEPATHS.sassSource, SOURCEPATHS.cssSource], ['sass']);
  //gulp.watch([SOURCEPATHS.htmlSource], ['copy']);
  gulp.watch([SOURCEPATHS.jsSource], ['scripts']);
  gulp.watch([SOURCEPATHS.imgSource], ['images']);
  gulp.watch([SOURCEPATHS.htmlSource, SOURCEPATHS.htmlPartials], ['html']);
});

gulp.task('default', ['watch']);
