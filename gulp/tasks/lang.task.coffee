'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'lang', ['lang:build']

    gulp.task 'lang:build', ['build:pre'], ->

        distPath = (moduleName, langName) ->
            config.target + switch
                when args.DEBUG
                    "#{config.fsPath}/i18n/#{langName}/"
                when not args.DEBUG
                    _name = config.pluginMap?[moduleName]?.plugin_name ? """
                        lafite-#{moduleName}
                    """
                    "#{_name}/#{config.fsPath}/i18n/#{langName}/"

        gulp.src "#{config.source}{core,plugins/*}/i18n/*.json"
            .pipe $.tap (file) ->

                [moduleName, langName] = (file.path.match ///
                    ([\w_-]+)[\/\\]i18n[\/\\]([\w_-]+)\.json$
                ///i)[1..]

                fileName = config.pluginMap?[moduleName]?['flag_name']
                fileName = fileName ? moduleName

                gulp.src file.path
                    .pipe $.rename "#{fileName}.json"
                    # .pipe $.if not args.DEBUG, $.jsonmin()
                    .pipe gulp.dest distPath moduleName, langName

                return
