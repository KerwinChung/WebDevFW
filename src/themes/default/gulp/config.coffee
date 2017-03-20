'use strict'

module.exports = ( ) ->

    pkj = require("../package.json")

    pkj.source = "#{__dirname}/../src/"
    pkj.target = "#{__dirname}/../dist/"

    return pkj
