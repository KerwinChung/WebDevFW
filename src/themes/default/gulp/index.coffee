'use strict'

module.exports = ->

    gulp = require('gulp')
    $    = require('gulp-load-plugins')({ lazy: true })
    args = require('yargs').argv

    config = require('./config.coffee')()

    taskList = require('fs').readdirSync('./gulp/tasks/')
    taskList.forEach (file) ->
        require('./tasks/' + file)(gulp, config, $, args)

    gulp.task('help', $.taskListing)

    return
