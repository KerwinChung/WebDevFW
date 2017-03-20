'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'lint', ['lint:editorstyle', 'lint:coffee']

    gulp.task 'lint:editorstyle', ->

        gulp.src [
            "#{config.source}**"
            "#{config.test}}**"
            "gulp/**"
            "*.{json}"
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
        ]
            .pipe $.coffeelint()
            .pipe $.coffeelint.reporter 'coffeelint-stylish'
            .pipe $.coffeelint.reporter 'fail'
