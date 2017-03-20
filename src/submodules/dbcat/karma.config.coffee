'use strict'

module.exports = (config) ->
    TOP_PATH =

    config.set {
        frameworks : [
            'jasmine', 'should-sinon', 'should', 'sinon'
        ]
        browsers   : [
            'PhantomJS'
        ]
        singleRun      : true
        captureTimeout : 120 * 1000 #ms

        files : [
            "bower_components/angular/angular.js"
            "bower_components/angular-*/angular-*.js"

            "src/**/*.js"
            "src/**/*.coffee"
            "test/spec/*.js"
            "test/spec/*.coffee"
        ]

        preprocessors      :
            'src/**/*.coffee'  : ['coffee', 'coverage']
            'src/**/*.js'      : ['coverage']
            'test/**/*.coffee' : ['coffee']

        coffeePreprocessor:
            options:
                bare      : true
                sourceMap : false
            transformPath: (path) ->
                path.replace /\.coffee$/, '.js'

        reporters: [
            'junit'
            'coverage'
            'story'
        ]

        junitReporter:
            outputDir : "#{__dirname}/test/reports/junit/"
            suite     : 'unit'

        coverageReporter :
            type : 'cobertura'
            dir  : "#{__dirname}/test/reports/coverage/"

    }
    return
