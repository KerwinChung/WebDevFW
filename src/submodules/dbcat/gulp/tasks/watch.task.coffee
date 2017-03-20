'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'watch', () ->

        gulp.watch [
            "#{config.source}**/*.{js,coffee}"
            "#{config.test}spec/**/*.{js,coffee}"
            ], ['test', 'js']
