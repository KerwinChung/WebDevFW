'use strict'

module.exports = (config) ->
    config.set {
        frameworks : [
            'angular', 'angular-filesort'
            'jasmine', 'should'
        ]
        browsers   : [
            'PhantomJS'
        ]
        angular    : [
            'route'
            'animate'
            'messages'
            'mocks'
        ]
        singleRun      : true
        captureTimeout : 120 * 1000 #ms

        preprocessors:
            '**/*.coffee': ['coffee', 'coverage']
            'src/**/*.js': ['coverage']

        coffeePreprocessor:
            options:
                bare      : true
                sourceMap : false
            transformPath: (path) ->
                path.replace /\.coffee$/, '.js'

        reporters: [
            'story'
            'junit'
            'coverage'
        ]

        junitReporter:
            outputDir : "#{__dirname}/test/reports/junit/"
            suite     : 'unit'

        coverageReporter :
            type : 'cobertura'
            dir  : "#{__dirname}/test/reports/coverage/"
    }
    return
