'use strict'

path = require 'path'

module.exports = ( ) ->

    pkj = require("../package.json")

    pkj.source      =  path.normalize "#{__dirname}/../src/"
    pkj.targetPaths = [
        path.normalize "#{__dirname}/../build/"
        path.normalize "#{__dirname}/../dist/"
    ]

    pkj.test       = path.normalize "#{__dirname}/../test/"
    pkj.bowerPath  = path.normalize "#{__dirname}/../bower_components/"
    pkj.modulePath = path.normalize "#{__dirname}/../node_modules/"
    pkj.fsPath     = 'files/www/luci-static/lafite'

    moment = require 'moment'
    pkj.date =
        YYYY : moment().format('YYYY')

    return pkj
