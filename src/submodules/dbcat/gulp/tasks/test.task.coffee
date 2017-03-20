'use strict'

Server = (require 'karma').Server

module.exports = (gulp, config, $, args) ->

    gulp.task 'test', ->

        $.runSequence ['lint', 'test:prebuilt'], 'test:karma'

    gulp.task 'test:prebuilt', ->

        $.bower()

    gulp.task 'test:karma', (done) ->

        new Server {
            configFile : "#{config.test}../karma.config.coffee"
        }, done
        .start()
