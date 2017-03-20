'use strict'

Server = (require 'karma').Server
glob   = require 'glob'
lodash = require 'lodash'

module.exports = (gulp, config, $, args) ->

    gulp.task 'test', (done) ->
        return done() if args['without-test']
        $.runSequence 'test:ready', 'test:karma', 'test:clean', done

    gulp.task 'test:ready', (done) ->
        args.isTest = true
        $.runSequence 'js', done

    gulp.task 'test:karma', (done) ->
        if not args.test?
            $.runSequence 'test:karma:core', 'test:karma:plugins', done
        else if args.test is 'core'
            $.runSequence 'test:karma:core', done
        else
            $.runSequence 'test:karma:plugins', done

    defFiles = [
        # Library Files
        "#{config.modulePath}angular-translate/dist/*.min.js"
        "#{config.modulePath}angular-translate-loader-partial/angular-*.min.js"
        # Source Files
        "#{config.source}core/js/**/*.+(js|coffee)"
        "#{config.source}widgets/*/js/*.+(js|coffee)"
        # Submodule Files
        "#{config.source}submodules/*/dist/**/*.+(js|coffee)"
        # Test Files
        "#{config.test}karma/**/*.spec.+(js|coffee)"
    ]

    defPreprocessors =
        "**/*.coffee" : ['coffee']

    defJunitReporter =
        outputDir : "#{config.test}reports/junit/"
        suite     : 'unit'

    defCoverageReporter  =
        type : 'cobertura'
        dir  : "#{config.test}reports/coverage/"

    gulp.task 'test:karma:core', (done) ->
        files = defFiles.concat [
            "#{config.source}core/**/*.spec.+(js|coffee)"
            "#{config.source}widgets/**/*.spec.+(js|coffee)"
        ]

        preprocessors = { }
        (preprocessors[key] = val) for key, val of defPreprocessors
        (preprocessors[key] = val) for key, val of {
            "#{config.source}core/js/**/*.js" : ['coverage']
            "#{config.source}core/js/**/*.coffee" : ['coverage']
            "#{config.source}widgets/*/js/*.js" : ['coverage']
            "#{config.source}widgets/*/js/*.coffee" : ['coverage']
        }

        junitReporter =
            outputFile : 'core.xml'
        (junitReporter[key] = val) for key, val of defJunitReporter
        coverageReporter =
            reporters : [
                {
                    type : 'html'
                    subdir : 'core'
                }
                {
                    type : 'cobertura'
                    subdir : 'core'
                }
            ]

        (coverageReporter[key] = val) for key, val of defCoverageReporter

        new Server {
            configFile    : "#{config.test}../karma.config.coffee"

            files            : files
            preprocessors    : preprocessors
            junitReporter    : junitReporter
            coverageReporter : coverageReporter
        }, done
        .start()
        return

    gulp.task 'test:karma:plugins', ['build:pre', 'test:ready'], (done) ->

        path    = require 'path'
        Promise = require 'bluebird'

        Promise.resolve()
        .delay 1000
        .then ->
            (require 'glob').sync """
                #{config.source}plugins/#{args.test ? '*'}
            """
        .map (file) ->
            moduleName = path.basename file
            _name = config.pluginMap?[moduleName]?.plugin_name ? """
                lafite-#{moduleName}
            """

            files = defFiles.map (item) ->
                return item if -1 is item.indexOf 'core'
                return "#{config.source}core/js/**/!(*route).+(js|coffee)"
            .concat [
                "#{config.test}.tmp/#{_name}/**/*.+(js|coffee)"
                "#{config.source}plugins/#{moduleName}/test/*.+(js|coffee)"
            ]
            if config.pluginMap?[moduleName]?.depend_list?
                for item in config.pluginMap[moduleName].depend_list
                    files.push "#{config.test}.tmp/#{item}/**/*.+(js|coffee)"
                files = lodash.uniq files

            preprocessors = { }
            (preprocessors[key] = val) for key, val of defPreprocessors
            (preprocessors[key] = val) for key, val of {
                "#{config.test}.tmp/#{_name}/**/*.js" : ['coverage']
                "#{config.test}.tmp/#{_name}/**/*.coffee" : ['coverage']
            }

            junitReporter =
                outputFile : "#{_name}.xml"
            (junitReporter[key] = val) for key, val of defJunitReporter
            coverageReporter =
                reporters : [
                    {
                        type : 'html'
                        subdir : "#{_name}"
                    }
                    {
                        type : 'cobertura'
                        subdir : "#{_name}"
                    }
                ]
            for key, val of defCoverageReporter
                coverageReporter[key] = val

            {
                _name         : _name
                configFile    : path.normalize """
                    #{config.test}../karma.config.coffee
                """

                files            : files
                preprocessors    : preprocessors
                junitReporter    : junitReporter
                coverageReporter : coverageReporter
            }
        .each (obj) ->
            new Promise (resolve, reject) ->
                console.log "Running `#{obj._name}` Test Unit"
                new Server obj, (code) ->
                    if code isnt 0
                        return reject code
                    do resolve
                .start()
            .catch (code) ->
                done()
                process.exit code
        .done ->
            done()

        return

    gulp.task 'test:clean', ->

        gulp.src "#{config.test}.tmp"
            .pipe $.clean()
