'use strict'

path = require 'path'
md5  = require 'md5'

module.exports = (gulp, config, $, args) ->

    gulp.task 'luasrc', ->

        return if args.DEBUG

        $.runSequence [
            'luasrc:build'
        ]

    gulp.task 'luasrc:build', ['build:pre'], ->

        gulp.src [
            "#{config.source}plugins/*"
            "!#{config.source}plugins/config_*"
        ]
            .pipe $.tap (file) ->

                moduleName = path.basename file.path

                _name = config.pluginMap?[moduleName]?.plugin_name ? """
                    lafite-#{moduleName}
                """

                filename = ""
                newname  = ""
                gulp.src "#{file.path}/lua/*.lua"
                    .pipe $.tap (file) ->
                        filename = path.basename file.path, '.lua'
                        newname  = """
                            pbr#{(md5(_name+filename)).slice 0, 8}
                        """.toLowerCase()
                    .pipe $.replace ///
                        (?:module\("luci.pbr_module.)(.*?)(?:")
                    ///
                    , (_, word) ->
                        """
                            module("luci.pbr_module.#{newname}"
                        """
                    .pipe $.rename (path) ->
                        path.basename = newname
                        return
                    .pipe gulp.dest "#{config.target}#{_name}" + """
                        /files/usr/lib/lua/luci/pbr_module/
                    """
