'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'image', ['image:build']

    gulp.task 'image:build', [
        'image:build:core'
        'image:build:theme'
        'image:build:plugins'
    ]

    imgDistPath = (moduleName) ->
        switch
            when args.DEBUG
                "#{config.target}#{config.fsPath}/img"
            when not args.DEBUG
                _name = config.pluginMap?[moduleName]?.plugin_name ? """
                    lafite-#{moduleName}
                """
                "#{config.target}#{_name}/#{config.fsPath}/img"

    # Core Task
    gulp.task 'image:build:core', ['build:pre'], () ->

        icoFilter = $.filter '**/*.ico', { restore : true }
        icoDistPath = switch
            when args.DEBUG
                "#{config.target}files/www"
            when not args.DEBUG
                "#{config.target}pb-core/files/www"

        gulp.src [
            "#{config.source}core/img/**.{jpg,png,ico}"
            "#{config.source}widgets/**/img/**.{jpg,png}"
        ]
            .pipe icoFilter
            .pipe $.tap (file) ->
                gulp.src file.path
                    .pipe gulp.dest icoDistPath
            .pipe icoFilter.restore
            .pipe $.filter '**/*.{jpg,png}'
            .pipe $.if not args.DEBUG, $.imagemin {
                optimizationLevel : 3
                progressive       : true
                interlaced        : true
            }
            .pipe gulp.dest imgDistPath 'core'

    # Theme Task
    gulp.task 'image:build:theme', ['build:pre'], ->

        themeName = args.theme ? 'default'

        icoFilter = $.filter '**/*.ico', { restore : true }
        icoDistPath = switch
            when args.DEBUG
                "#{config.target}files/www"
            when not args.DEBUG
                "#{config.target}pb-core/files/www"

        gulp.src [
            "#{config.source}themes/#{themeName}/dist/{,**/}*.{jpg,png}"
        ]
            .pipe icoFilter
            .pipe $.tap (file) ->
                gulp.src file.path
                    .pipe gulp.dest icoDistPath
            .pipe icoFilter.restore
            .pipe $.filter '**/*.{jpg,png}'
            .pipe $.tap (file) ->
                gulp.src file.path
                    .pipe $.if not args.DEBUG, $.imagemin {
                        optimizationLevel : 3
                        progressive       : true
                        interlaced        : true
                    }
                    .pipe gulp.dest imgDistPath 'core'

    # Plugin Task
    gulp.task 'image:build:plugins', ['build:pre'], ->
        gulp.src ["#{config.source}plugins/*"]
            .pipe $.tap (file) ->
                pathname = require('path').basename file.path
                gulp.src [
                    "#{config.source}plugins/#{pathname}/img/**/*.{jpg,png}"
                ]
                    .pipe $.if not args.DEBUG, $.imagemin {
                        optimizationLevel : 3
                        progressive       : true
                        interlaced        : true
                    }
                    .pipe gulp.dest imgDistPath pathname
