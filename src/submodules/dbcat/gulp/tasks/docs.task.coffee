'use strict'

module.exports = (gulp, config, $, args) ->

    config.docs = "#{config.target}../docs/"

    gulp.task 'docs', ->

        $.runSequence 'docs:js', 'docs:dest'

    gulp.task 'docs:js', ->

        gulp.src "#{config.source}**/*.{js,coffee}"
            .pipe $.if /\.coffee$/, $.coffee()
            .pipe $.replace '/*', '/**'
            .pipe $.replace /{{(\w+)(\.\w*)*}}/g, (word..., offset, string) ->
                _config = config
                for item in word[1..] when item?
                    item = item.replace '.', '' if /\./.test item
                    _config = _config[item] if _config[item]?

                return _config if config isnt _config
                return word[0]
            .pipe gulp.dest "#{config.docs}js/"

    gulp.task 'docs:dest', ->
        gulp.src "#{config.docs}js/**/*.js"
            .pipe $.jsdoc config.docs
