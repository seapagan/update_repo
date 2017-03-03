var gulp = require('gulp');
var sass = require('gulp-sass');
var browserSync =  require('browser-sync');
var reload = browserSync.reload;
var autoprefixer = require('gulp-autoprefixer');
var browserify = require('gulp-browserify');
var clean = require('gulp-clean');
var concat = require('gulp-concat');
var merge = require('merge-stream');

var SOURCEPATHS = {
  sassSource : 'web/sass/*.scss',
  cssSource  : 'web/css/*.css',
  htmlSource : 'web/*.html',
  jsSource   : 'web/js/**',
  fontsource : 'web/fonts/**'
};

var APPPATH = {
  root  : 'docs/',
  css   : 'docs/css',
  js    : 'docs/js',
  fonts : 'docs/fonts'
};

gulp.task('clean-html', function() {
  return gulp.src(APPPATH.root + '/*.html', {read: false, force: true})
    .pipe(clean());
});

gulp.task('clean-scripts', function() {
  return gulp.src(APPPATH.js + '/*.js', {read: false, force: true})
    .pipe(clean());
});

gulp.task('clean-fonts', function() {
  return gulp.src(APPPATH.fonts + '/**', {read: false, force: true})
    .pipe(clean());
});

gulp.task('sass', function() {
  var bootstrapCSS = gulp.src('./node_modules/bootstrap/dist/css/bootstrap.css');
  var sassFiles;
  var cssFiles = gulp.src(SOURCEPATHS.cssSource);

  sassFiles = gulp.src(SOURCEPATHS.sassSource)
    .pipe(autoprefixer())
    .pipe(sass({outputStyle: 'expanded'}).on('error', sass.logError));
    return merge(sassFiles, cssFiles, bootstrapCSS)
      .pipe(concat('site.css'))
      .pipe(gulp.dest(APPPATH.css));
});

gulp.task('scripts', ['clean-scripts'], function() {
  gulp.src(SOURCEPATHS.jsSource)
    .pipe(concat('main.js'))
    .pipe(browserify())
    .pipe(gulp.dest(APPPATH.js));
});

gulp.task('copy', ['clean-html'], function() {
  gulp.src(SOURCEPATHS.htmlSource)
    .pipe(gulp.dest(APPPATH.root));
});

gulp.task('fonts', ['clean-fonts'], function() {
  gulp.src(SOURCEPATHS.fontsource)
    .pipe(gulp.dest(APPPATH.fonts));
});

gulp.task('serve', ['sass'], function() {
  browserSync.init([APPPATH.css + '/*.css', APPPATH.root + '/*.html', APPPATH.js + '/*.js'], {
    server: {
      baseDir : APPPATH.root
    }
  })
});

gulp.task('watch', ['serve', 'sass', 'copy', 'clean-html', 'clean-scripts', 'scripts', 'fonts', 'clean-fonts'], function() {
  gulp.watch([SOURCEPATHS.sassSource, SOURCEPATHS.cssSource], ['sass']);
  gulp.watch([SOURCEPATHS.htmlSource], ['copy']);
  gulp.watch([SOURCEPATHS.jsSource], ['scripts']);
  gulp.watch([SOURCEPATHS.fontsource], ['fonts']);
});

gulp.task('default', ['watch']);