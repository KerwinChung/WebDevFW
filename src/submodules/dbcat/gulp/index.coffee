'use strict'

module.exports = ( ) ->
    gulp = require('gulp')
    $    = require('gulp-load-plugins')({ lazy: true })
    args = require('yargs')
        .boolean('DEBUG').alias('d', 'DEBUG')
        .argv

    config = require('./config.coffee')()
    config.target = if (args.DEBUG)
        config.targetPaths[0]
    else
        config.targetPaths[1]

    taskList = require('fs').readdirSync('./gulp/tasks/')
    taskList.forEach (file) ->
        require('./tasks/' + file)(gulp, config, $, args)

    gulp.task('help', $.taskListing)
