'use strict'

browserSync = require 'browser-sync'

module.exports = (gulp, config, $, args) ->

    themeName = args.theme ? 'default'

    gulp.task 'css', ->

        $.runSequence 'css:build'

    gulp.task 'css:build', ['css:build:root', 'css:build:plugins']

    distPath = (moduleName) ->
        switch
            when args.DEBUG
                "#{config.target}#{config.fsPath}/css"
            when not args.DEBUG
                _name = config.pluginMap?[moduleName]?.plugin_name ? """
                    lafite-#{moduleName}
                """
                "#{config.target}#{_name}/#{config.fsPath}/css"

    gulp.task 'css:build:root', ['build:pre'], ->

        configName = args.config ? args.theme ? 'default'

        gulp.src [
            "#{config.source}themes/#{themeName}/dist/{**/,}*.min.css"
            "#{config.source}{core,widgets}/**/css/**/*.{css,styl}"
        ]
            .pipe $.wait 2000
            .pipe $.if '*.styl', $.stylus()
            .pipe $.autoprefixer '> 1% in CN', 'last 2 versions'
            .pipe $.concat 'style.css'
            .pipe $.if not args.DEBUG, $.csso()
            .pipe $.if not args.DEBUG, $.rename('style.min.css')
            .once 'end', browserSync.stream
            .pipe gulp.dest distPath "config_#{configName}"

        gulp.src [
            "#{config.source}themes/#{themeName}/dist/*.{eot,svg,ttf,woff}"
        ]
            .pipe gulp.dest distPath "config_#{configName}"

    gulp.task 'css:build:plugins', ['build:pre'], ->

        gulp.src ["#{config.source}plugins/*"]
            .pipe $.tap (file) ->
                pathname = require('path').basename file.path
                gulp.src [
                    "#{config.source}plugins/#{pathname}/css/{**/,}*.{css,styl}"
                ]
                    .pipe $.if /\.styl$/, $.stylus()
                    .pipe $.autoprefixer '> 1% in CN', 'last 2 versions'
                    .pipe $.concat "#{pathname}.css"
                    .pipe $.if not args.DEBUG, $.csso()
                    .once 'end', browserSync.stream
                    .pipe gulp.dest distPath pathname
