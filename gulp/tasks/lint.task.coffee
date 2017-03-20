'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'lint', ['lint:editorstyle', 'lint:coffee']

    gulp.task 'lint:editorstyle', ->

        gulp.src [
            "#{config.source}**"
            "#{config.test}}**"
            "gulp/**"
            "*.{js,json,md}"
            "!#{config.source}{submodules,themes}/**"
            "!**/*.{jpg,png,ico}"
        ]
            .pipe $.lintspaces({
                editorconfig : '.editorconfig'
            })
            .pipe $.lintspaces.reporter({
                breakOnWarning : true
            })

    gulp.task 'lint:coffee', ->

        gulp.src [
            "#{config.source}{,**/}*.coffee"
            "#{config.test}{,**/}*.coffee"
            "{.,gulp/**/}/*.coffee"
            "!#{config.source}{submodules,themes}/**"
        ]
            .pipe $.coffeelint()
            .pipe $.coffeelint.reporter 'coffeelint-stylish'
            .pipe $.coffeelint.reporter 'fail'
