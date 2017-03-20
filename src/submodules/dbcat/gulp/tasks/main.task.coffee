'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'default', ->

        $.runSequence 'clean', ['build', 'docs'], ['lint', 'test']

    gulp.task 'clean', ->

        gulp.src config.targetPaths
            .pipe $.clean()

    gulp.task 'build', ->

        $.runSequence 'js'
