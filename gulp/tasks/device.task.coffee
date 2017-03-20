'use strict'

module.exports = (gulp, config, $, args) ->

    gulp.task 'toDev', ->

        switch

            when not args.DEBUG

                gulp.src "#{config.target}*"
                    .pipe $.tap (file) ->

                        gulp.src "#{file.path}/files/**"
                            .pipe $.sftp {
                                host : '192.168.1.1'
                                auth : 'main'
                                remotePath : '/'
                            }

            when args.DEBUG
                gulp.src "#{config.target}files/**"
                    .pipe $.sftp {
                        host : '192.168.1.1'
                        auth : 'main'
                        remotePath : '/'
                    }
