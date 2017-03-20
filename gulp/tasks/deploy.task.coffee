'use strict'

Promise = require 'bluebird'
glob    = require 'glob'
path    = require 'path'

module.exports = (gulp, config, $, args) ->

    # generate files with version
    gulp.task 'rev', ->
        if not args.DEBUG
            $.runSequence [
                'rev:core_replace', 'rev:plugins_append'
            ], 'rev:clean'


    # #########################
    #
    # Core 相关
    #
    # #########################

    gulp.task 'rev:core', ->
        gulp.src [
            "#{config.target}lafite-core/files/www/**/*.{js,css}"
        ]
            .pipe $.wait 50
            .pipe $.rev()
            .pipe gulp.dest "#{config.target}lafite-core/files/www/"
            .pipe $.rev.manifest()
            .pipe gulp.dest "#{config.target}rev"

    gulp.task 'rev:core_replace', ['rev:core'], ->
        gulp.src [
            "#{config.target}rev/*.json"
            "#{config.target}lafite-core/files/www/web/*.htm{l,}"
        ]
            .pipe $.wait 50
            .pipe $.revCollector()
            .pipe $.if /index\.html$/, gulp.dest """
                #{config.target}lafite-core/files/www/web/
            """

    # #########################
    #
    # Plugin 相关
    #
    # #########################

    gulp.task 'rev:plugins', ->

        list = glob.sync """
            #{config.target}!(lafite-core|lafite-config*|rev)
        """

        promises = list.map (item) -> new Promise (resolve) ->
            gulp.src [
                "#{item}/files/www/**/*.js"
            ]
                .pipe $.rev()
                .pipe gulp.dest "#{item}/files/www/"
                .pipe $.rev.manifest()
                .pipe gulp.dest "#{config.target}rev/#{path.basename item}/"
                .once 'end', resolve

        Promise.all promises

    gulp.task 'rev:plugins_append', ['rev:plugins'], ->

        promises = [ ]
        list     = [ ]
        _list = glob.sync("""
            #{config.target}!(lafite-core|lafite-config*|rev)
        """)
        .map (item) ->
            return path.basename item
        .map (item) ->
            fileList = glob.sync(
                "#{config.target}#{item}/files/etc/uci-defaults/#{item}"
            ).concat glob.sync("""
                #{config.target}#{item}/files/etc/pbr-defaults/#{item}/postinst
            """).concat glob.sync("""
                #{config.target}rev/#{item}/rev-manifest.json
            """)
            list.push fileList if fileList.length is 3
            return item

        list.map (moduleFiles) ->
            for filepath in moduleFiles when /\.json$/i.test filepath
                jsonPath = filepath
                break
            json = require jsonPath
            s = (num = 0) ->
                return (new Array(num)).join(' ') ? ''
            for filepath in moduleFiles when !/\.json$/i.test filepath
                promises.push new Promise (resolve) ->
                    gulp.src(filepath).pipe $.replace "exit 0", (word) ->
                        content = "uci batch <<-EOF\n"

                        content += """
                            #{s 4}set lafite.${MODULE_NAME}.jspath='/#{val}'\n
                        """ for _, val of json
                        content += "#{s 4}commit lafite\nEOF"
                        word = "#{content}\n\n#{word}"
                        return word
                    .pipe gulp.dest path.dirname filepath
                    .once 'end', resolve

        Promise.all promises

        # console.log _list

    # #########################
    #
    # 删除相关
    #
    # #########################

    gulp.task 'rev:clean', () ->
        deleteList = [ "#{config.target}rev" ]

        list = glob.sync """
            #{config.target}rev/*/rev-manifest.json
        """
        for key, _ of require("#{config.target}rev/rev-manifest.json")
            deleteList.push "#{config.target}lafite-core/files/www/#{key}"
        for item in list
            for key, _ of require(item)
                moduleName = path.basename path.dirname item
                deleteList.push "#{config.target}#{moduleName}/files/www/#{key}"

        gulp.src deleteList
            .pipe $.wait 50
            .pipe $.clean()
