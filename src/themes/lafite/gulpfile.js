
var gulp = require('gulp');


var stylus   = require('gulp-stylus');
var concat   = require('gulp-concat');
var rename   = require('gulp-rename');
var clean    = require('gulp-clean');
var minCss   = require('gulp-minify-css');
var connect  = require('gulp-connect');
var replace  = require('gulp-replace');
var csscomb  = require('gulp-csscomb');

var runSequence = require('gulp-run-sequence');

gulp.task('stylus', function(){
	gulp.src('src/css/stylus/*/*.styl')
		.pipe(stylus())
		.pipe(concat('style.css'))
		.pipe(csscomb())
		.pipe(replace(/^\s*({|.*,|.*;)?\n/gm, '$1'))
		.pipe(gulp.dest('dist/css'))
		.pipe(minCss())
		.pipe(rename('style.min.css'))
		.pipe(gulp.dest('dist/css'))
		.pipe(connect.reload());
});

gulp.task('clean', function(){
	gulp.src('dist', {read: false})
		.pipe(clean());
});

gulp.task('watch', function(){
	gulp.watch('src/css/stylus/*/*.styl', ['stylus']);
});

gulp.task('webserver', function(){
	connect.server({
		livereload: true
	});
});
gulp.task('default', function(){
	runSequence('clean', 'stylus')
});
gulp.task('serve', ['stylus', 'webserver', 'watch']);

