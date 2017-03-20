'use strict'

module.exports = ( ) ->

    pkj = require("../package.json")

    pkj.source      = "#{__dirname}/../src/"
    pkj.targetPaths = [
        "#{__dirname}/../build/"
        "#{__dirname}/../dist/"
    ]

    pkj.test      = "#{__dirname}/../test/"
    pkj.bowerPath = "#{__dirname}/../bower_components/"

    moment = require 'moment'
    pkj.date =
        YYYY = moment().format('YYYY')

    return pkj
