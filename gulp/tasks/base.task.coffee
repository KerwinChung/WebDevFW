'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'clean', ->

        gulp.src config.targetPaths
            .pipe $.clean()

    gulp.task 'build:pre', ->

        config.pluginMap = { }

        gulp.src([
            "#{config.source}plugins/*"
        ]).pipe $.tap (file) ->
            pathname = require('path').basename file.path

            gulp.src [
                "#{config.source}plugins/#{pathname}/data/**/Makefile"
                "#{config.source}plugins/#{pathname}/plugin.json"
            ]
                .pipe $.tap (file) ->
                    config.pluginMap[pathname] ?= { }
                    config.pluginMap[pathname]._path ?= """
                        #{config.source}plugins/#{pathname}/
                    """
                    return
                .pipe $.if /Makefile$/, $.data (file) ->
                    content = String file.contents
                    config.pluginMap[pathname] ?= { }
                    config.pluginMap[pathname].plugin_name ?= (content.match ///
                        (?::=\s*)(.*)
                    ///)[1]
                .pipe $.if /plugin\.json$/, $.data (file) ->
                    content = JSON.parse String file.contents
                    config.pluginMap[pathname] ?= { }
                    for key, value of content ? { }
                        config.pluginMap[pathname][key] = value
