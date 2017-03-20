'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'js', ->

        gulp.src "#{config.source}**/*.{js,coffee}"
            .pipe $.replace /\/cgi-bin\/luci[\w\/]+/g, (word) ->
                return  word
                    .replace(/i/g, '#{([![]]+[][[]])[+!+[]+[+[]]]}')
                    .replace(/a/g, '#{(![]+[])[+!+[]]}')
                    .replace(/u/g, '#{([][[]]+[])[+[]]}')
                    .replace(/r/g, '#{(!![]+[])[+!+[]]}')
            .pipe $.plumber()
            .pipe $.if /\.coffee$/, $.coffee()
            .pipe $.ngAnnotate()
            .pipe $.if not args.DEBUG, $.uglify()
            .pipe gulp.dest "#{config.target}"
