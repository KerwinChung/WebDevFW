'use strict'

browserSync = require 'browser-sync'

module.exports = (gulp, config, $, args) ->

    gulp.task 'js', ['js:build', 'js:copy']

    gulp.task 'js:build', [
        'js:build:root'
        'js:build:config'
        'js:build:plugins'
    ]

    testPath = (moduleName) ->
        """
            #{config.test}.tmp/
        """ + (config.pluginMap?[moduleName]?.plugin_name ? """
            lafite-#{moduleName}
        """)

    distPath = (moduleName) ->
        switch
            when args.DEBUG
                "#{config.target}#{config.fsPath}/js"
            when not args.DEBUG
                _name = config.pluginMap?[moduleName]?.plugin_name ? """
                    lafite-#{moduleName}
                """
                "#{config.target}#{_name}/#{config.fsPath}/js"

    gulp.task 'js:build:root', ['build:pre'], ->

        gulp.src [
            "#{config.source}core/js/**/*.{js,coffee}"
            "#{config.source}widgets/**/*.{js,coffee}"
            "#{config.source}submodules/*/dist/**/*.{js,coffee}"
        ]
            .pipe $.filter ['**', '!**/*.spec.*']
            .pipe $.if '*.coffee', $.coffee()
            .pipe $.ngAnnotate()
            .pipe $.concat 'script.js'
            .pipe $.if args.DEBUG, $.replace ///
                (\bDEBUG\w+\s+=\s+)false
            ///g, "$1true"
            .pipe $.if not args.DEBUG, $.uglify()
            .pipe $.if not args.DEBUG, $.rename 'script.min.js'
            .once 'end', browserSync.stream
            .pipe gulp.dest distPath 'core'

    # ####################################
    #
    # Build Config JS
    #
    # ####################################
    gulp.task 'js:build:config', ['build:pre'], ->

        if args.isTest
            gulp.src [
                "#{config.source}plugins/config_*"
            ]
                .pipe $.tap (file) ->
                    moduleName = require('path').basename(file.path)
                    modulePath = "#{config.source}plugins/#{moduleName}/"
                    gulp.src [
                        "#{modulePath}/{**/,}*.{js,coffee}"
                    ]
                        .pipe gulp.dest testPath moduleName
            return

        configName = args.config ? args.theme ? 'default'

        gulp.src [
            "#{config.source}plugins/config_#{configName}/{**/,}*.{js,coffee}"
        ]
            .pipe $.if args.isTest, gulp.dest testPath "config_#{configName}"
            .pipe $.if '*.coffee', $.coffee()
            .pipe $.ngAnnotate()
            .pipe $.if not args.DEBUG, $.uglify()
            .pipe $.concat 'config.js'
            .pipe $.if not args.DEBUG, $.rename 'config.min.js'
            .once 'end', browserSync.stream
            .pipe $.if not args.DEBUG,
                (gulp.dest distPath "config_#{configName}"),
                gulp.dest distPath 'core'

    # ####################################
    #
    # Build Plugin JS
    #
    # ####################################
    gulp.task 'js:build:plugins', ['build:pre'], ->

        gulp.src([
            "#{config.source}plugins/!(config_)*"
        ]).pipe $.tap (file) ->

            pathname = require('path').basename file.path

            src = gulp.src [
                "#{config.source}plugins/#{pathname}/js/**/*.{js,coffee}"
            ]

            if args.isTest
                src
                    .pipe $.replace /\.register(?=.)/g, ''
                    .pipe gulp.dest testPath pathname
            else
                fileName = config.pluginMap?[pathname]?['flag_name']
                fileName = fileName ? pathname
                src
                    .pipe $.if '*.coffee', $.coffee()
                    .pipe $.ngAnnotate()
                    .pipe $.concat "#{fileName}.js"
                    .pipe $.if not args.DEBUG, $.uglify()
                    .once 'end', browserSync.stream
                    .pipe gulp.dest distPath pathname

    # Copy JS Library
    gulp.task 'js:copy', ['js:bower:copy']

    gulp.task 'js:bower', (done) ->
        $.runSequence ['js:bower:install'], 'js:bower:copy', done

    gulp.task 'js:bower:install', (done) ->
        # $.bower()
        return done()

    gulp.task 'js:bower:copy', ['js:bower:install'], () ->

        bowerDistPath = switch
            when args.DEBUG
                "#{config.target}#{config.fsPath}/../resource"
            when not args.DEBUG
                "#{config.target}lafite-core/#{config.fsPath}/../resource"

        lib_ie = gulp.src [
            "#{config.modulePath}html5shiv/dist/html5shiv.min.js"
            "#{config.modulePath}JSON/json2.js"
        ]
            .pipe $.concat 'ie-library.min.js'
            # .pipe gulp.dest bowerDistPath

        lib = gulp.src [
            "#{config.modulePath}scriptjs/dist/script.min.js"
            "#{config.modulePath}angular/*.min.js"
        ]
            .pipe $.if /angular/, $.replace /.*sourceMappingURL.*/, ''
            # .pipe gulp.dest bowerDistPath

        lib_angular = gulp.src [
            # "#{config.bowerPath}angular-*/*.min.js"
            "#{config.modulePath}angular-{animate,messages,route}/*.min.js"
            "#{config.modulePath}angular-translate/dist/angular-*.min.js"
            "#{config.modulePath}angular-translate-*/angular-*.min.js"
            "!#{config.modulePath}angular-mocks/*"
        ]
            .pipe $.if /angular/, $.replace /.*sourceMappingURL.*/, ''
            .pipe $.concat 'angular-library.min.js'

        require('merge2')(lib, lib_ie, lib_angular)
            .pipe gulp.dest bowerDistPath
