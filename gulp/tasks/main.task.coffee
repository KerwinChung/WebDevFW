'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'default', ['clean'], () ->
        $.runSequence 'build', ['lint', 'test'], 'rev'

    gulp.task 'build', [
        'html', 'js', 'css'
        'image', 'lang', 'data', 'luasrc'
    ]
