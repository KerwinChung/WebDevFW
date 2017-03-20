'use strict'

browserSync = require 'browser-sync'

module.exports = (gulp, config, $, args) ->

    gulp.task 'html', ['html:build']

    htmlminOptions =
        collapseWhitespace : true
        removeComments     : true

    jadeOptions =
        pretty : true

    gulp.task 'html:build', [
        'html:build:root'
        'html:build:index'
        'html:build:plugins'
        'html:build:config'
    ]

    gulp.task 'html:build:index', () ->

        indexDistPath = switch
            when args.DEBUG
                "#{config.target}#{config.fsPath}/../../web"
            when not args.DEBUG
                "#{config.target}lafite-core/#{config.fsPath}/../../web"

        gulp.src [
            "#{config.source}core/htm/index.{html,htm,jade}"
        ]
            .pipe $.if /\.jade$/, $.jade(jadeOptions)
            .pipe $.if not args.DEBUG, $.processhtml()
            .pipe $.if not args.DEBUG, $.htmlmin htmlminOptions
            .pipe $.rename 'index.html'
            .once 'end', browserSync.stream
            .pipe gulp.dest indexDistPath

    distPath = (moduleName) ->
        switch
            when args.DEBUG
                "#{config.target}#{config.fsPath}/htm"
            when not args.DEBUG
                _name = config.pluginMap?[moduleName]?.plugin_name ? """
                    lafite-#{moduleName}
                """
                "#{config.target}#{_name}/#{config.fsPath}/htm"

    gulp.task 'html:build:root', () ->

        gulp.src [
            "#{config.source}core/htm/*.{html,htm,jade}"
            "#{config.source}widgets/**/*.{html,htm,jade}"
            "!#{config.source}core/htm/index.{html,htm,jade}"
        ]
            .pipe $.if /\.jade$/, $.jade(jadeOptions)
            .pipe $.if not args.DEBUG, $.processhtml()
            .pipe $.if not args.DEBUG, $.htmlmin htmlminOptions
            .pipe $.rename (path) ->
                path.extname = '.htm'
                return
            .once 'end', browserSync.stream
            .pipe gulp.dest distPath 'core'

    # ####################################
    #
    # Build Plugin HTML
    #
    # ####################################
    gulp.task 'html:build:plugins', ['build:pre'], () ->

        gulp.src([
            "#{config.source}plugins/*"
            "!#{config.source}plugins/config_*"
        ]).pipe $.tap (file) ->

            pathname = require('path').basename file.path

            gulp.src [
                "#{config.source}plugins/#{pathname}/htm/*.{htm,html,jade}"
            ]
                .pipe $.if /\.jade$/, $.jade(jadeOptions)
                .pipe $.if not args.DEBUG, $.processhtml()
                .pipe $.if not args.DEBUG, $.htmlmin htmlminOptions
                .pipe $.rename """
                    #{config.pluginMap?[pathname]?['flag_name'] ? pathname}.htm
                """
                .once 'end', browserSync.stream
                .pipe gulp.dest distPath pathname


    # ####################################
    #
    # Build Config HTML
    #
    # ####################################
    gulp.task 'html:build:config', ['build:pre'], ->

        gulp.src([
            "#{config.source}plugins/config_*"
        ]).pipe $.tap (file) ->

            pathname = require('path').basename file.path

            gulp.src [
                "#{config.source}plugins/#{pathname}/htm/*.{htm,html,jade}"
                "#{config.source}plugins/#{pathname}/htm/**/*.{htm,html,jade}"
            ]
                .pipe $.if /\.jade$/, $.jade(jadeOptions)
                .pipe $.if not args.DEBUG, $.processhtml()
                .pipe $.if not args.DEBUG, $.htmlmin htmlminOptions
                .pipe $.rename (path) ->
                    path.extname = '.htm'
                    return
                .once 'end', browserSync.stream
                .pipe gulp.dest distPath pathname
