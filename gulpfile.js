var gulp = require('gulp');
var sass = require('gulp-sass');
var browserSync =  require('browser-sync');
var reload = browserSync.reload;

var SOURCEPATHS = {
  sassSource : 'sass/*.scss'
}

var APPPATH = {
  root : '.',
  css  : 'css',
  js   : 'js'
}

gulp.task('sass', function() {
  return gulp.src(SOURCEPATHS.sassSource)
    .pipe(sass({outputStyle: 'expanded'}).on('error', sass.logError))
    .pipe(gulp.dest(APPPATH.css));
});

gulp.task('serve', ['sass'], function() {
  browserSync.init([APPPATH.css + '/*.css', APPPATH.root + '/*.html', APPPATH.js + '/*.js'], {
    server: {
      baseDir : APPPATH.root
    }
  })
});

gulp.task('watch', ['serve', 'sass'], function() {
  gulp.watch([SOURCEPATHS.sassSource], ['sass'])
});

gulp.task('default', ['watch']);
