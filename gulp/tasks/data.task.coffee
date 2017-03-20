'use strict'

git  = require 'git-log-utils'
glob = require 'glob'

module.exports = (gulp, config, $, args) ->

    gulp.task 'data', ->

        return if args.DEBUG

        $.runSequence [
            'data:makefile'
            'data:script'
            'data:luasrc'
            'data:config'
        ]

    gulp.task 'data:makefile', ['build:pre'], ->

        gulp.src "#{config.source}{core,plugins}/**/data/Makefile"
            .pipe $.tap (file) ->

                moduleName = (file.path.match ///
                    ([\w-_]+)[\\\/]data[\\\/]Makefile$
                ///)[1]

                _name = config.pluginMap?[moduleName]?.plugin_name ? """
                    lafite-#{moduleName}
                """
                # for key, value of require()
                gulp.src file.path
                    .pipe $.replace /({{)[\w\.]+(}})/g, (word) ->
                        arr     = word.replace(/[{}]/g, '').split '.'
                        _config = config
                        for item in arr
                            if _config[item]?
                                _config = _config[item]
                            else if _config.pluginMap[moduleName]?[item]?
                                _config = _config.pluginMap[moduleName][item]
                            else
                                return word

                        return _config
                    .pipe $.replace /({{)release(}})/g, (word) ->
                        return git.getCommitHistory(file.path.replace ///
                            [\\\/]data[\\\/]Makefile$
                        ///, '').length
                    .pipe $.replace /({{)hashcode(}})/g, (word) ->
                        return git.getCommitHistory(file.path.replace ///
                            [\\\/]data[\\\/]Makefile$
                        ///, '')[0]?['id'] ? "00000000"
                    .pipe $.replace /({{)depend_list_text(}})/g, (word) ->
                        arr = [ 'lafite-core' ]
                        if (/plugins[\\\/]/.test file.path) and
                                config.pluginMap?[moduleName]?.depend_list?
                            arr = config.pluginMap[moduleName].depend_list
                        return (arr.map (item) ->
                            return "+#{item}").join ' '
                    .pipe gulp.dest "#{config.target}#{_name}"

    gulp.task 'data:script', ['build:pre'], ->

        gulp.src [
            "#{config.source}{core,plugins}/**/data/conffiles"
            "#{config.source}{core,plugins}/**/data/preinst"
            "#{config.source}{core,plugins}/**/data/postinst"
            "#{config.source}{core,plugins}/**/data/prerm"
            "#{config.source}{core,plugins}/**/data/postrm"
        ]
            .pipe $.tap (file) ->

                moduleName = (file.path.match ///
                    ([\w-_]+)[\\\/]data[\\\/]\w+$
                ///)[1]
                _name = config.pluginMap?[moduleName]?.plugin_name ? """
                    lafite-#{moduleName}
                """

                distPath = "#{config.target}#{_name}/files/"
                isPostinst = /postinst$/.test file.path

                gulp.src file.path
                    .pipe $.replace /({{)[\w\.]+(}})/g, (word) ->
                        arr     = word.replace(/[{}]/g, '').split '.'
                        _config = config
                        for item in arr
                            if _config[item]?
                                _config = _config[item]
                            else if _config.pluginMap[moduleName]?[item]?
                                _config = _config.pluginMap[moduleName][item]
                            else
                                return word

                        return _config
                    .pipe $.replace /({{)release(}})/g, (word) ->
                        return git.getCommitHistory(file.path.replace ///
                            [\\\/]data[\\\/]Makefile$
                        ///, '').length
                    .pipe $.replace /({{)hashcode(}})/g, (word) ->
                        return git.getCommitHistory(file.path.replace ///
                            [\\\/]data[\\\/]Makefile$
                        ///, '')[0]?['id'] ? "00000000"
                    .pipe gulp.dest """
                        #{distPath}/etc/pbr-defaults/#{_name}/
                    """
                    .pipe $.if isPostinst
                            , $.rename "#{_name}"
                    .pipe $.if isPostinst
                            , gulp.dest "#{distPath}/etc/uci-defaults/"

    gulp.task 'data:luasrc', ->

        gulp.src "#{config.source}core/data/luasrc/**"
            .pipe gulp.dest "#{config.target}lafite-core/files/usr/lib/lua/luci"

    gulp.task 'data:config', ->

        gulp.src "#{config.source}core/data/config/**"
            .pipe gulp.dest "#{config.target}lafite-core/files/etc/config"
