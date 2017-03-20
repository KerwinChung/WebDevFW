'use strict'

browserSync = require('browser-sync').create()

module.exports = (gulp, config, $, args) ->

    gulp.task 'live', ->

        if not args.DEBUG
            console.log "Please use Debug mode, e.g. `gulp live -d`."
            return

        $.runSequence 'build', 'live:server', [
            'live:reload', 'live:stream'
        ]

    gulp.task 'live:server', () ->
        browserSync.init {
            port        : 3000
            open        : false
            notify      : true
            reloadDelay : 500
            server      : "#{config.target}files/www/"
            middleware  : [
                require('http-proxy-middleware')('/cgi-bin/luci', {
                    'target'       : 'http://192.168.1.1'
                    'changeOrigin' : true
                })
            ]
        }

    gulp.task 'live:reload', () ->

        gulp.watch [
            "#{config.source}{core,plugins,widgets}/{,**}/*.json"
            "#{config.source}{core,plugins,widgets}/{,**}/*.{html,htm,jade}"
            "#{config.source}{submodules,themes}/*/dist/{,**}/*.{json}"
            "#{config.source}{submodules,themes}/*/dist/{,**}/*.{html,htm,jade}"
        ], { read: false }, (event) ->
            console.log "File #{event.path} was #{event.type}"

            $.runSequence switch
                when /\.(html|htm|jade|pug)$/i.test event.path
                    'html:build'
                when /\.json$/i.test event.path
                    'lang:build'
        .on 'change', (event) ->
            browserSync.reload()

    gulp.task 'live:stream', () ->

        gulp.watch [
            "#{config.source}{core,plugins,widgets}/{,**}/*.{js,coffee}"
            "#{config.source}{core,plugins,widgets}/{,**}/*.{css,styl}"
            "#{config.source}{core,plugins,widgets}/{,**}/*.{jpg,png}"
            "#{config.source}{submodules,themes}/*/dist/{,**}/*.{js,coffee}"
            "#{config.source}{submodules,themes}/*/dist/{,**}/*.{css,styl}"
            "#{config.source}{submodules,themes}/*/dist/{,**}/*.{jpg,png}"
        ], { read: false }, (event) ->
            console.log "File #{event.path} was #{event.type}"
            $.runSequence switch
                when /\.(js|coffee)$/i.test event.path
                    'js:build'
                when /\.(css|styl)$/i.test event.path
                    'css:build'
                when /\.(jpg|png)$/i.test event.path
                    'image:build'
        .on 'change', (event) ->
            browserSync.reload()
