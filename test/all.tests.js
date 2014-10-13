require.config({
    paths: {
        boot: '../lib/jasmine/boot',
        'jasmine-html': '../lib/jasmine/jasmine-html',
        jasmine: '../lib/jasmine/jasmine',
        'trace': '../build/trace'
    },
    config: {
        'trace': {
            levels: {
                custom: {
                    color: '#0000FF',
                    level: 3
                }
            },
            options: {
                level: 9,
                lengths: {
                    file: 10,
                    func: 20,
                    line: 2
                }
            }
        }
    },
    shim: {
        jasmine: {
            exports: 'window.jasmineRequire'
        },
        'jasmine-html': {
            deps: [
                'jasmine'
            ],
            exports: 'window.jasmineRequire'
        },
        boot: {
            deps: [
                'jasmine',
                'jasmine-html'
            ],
            exports: 'window.jasmineRequire'
        }
    },
    scalejs: {
        extensions: [
            'browser',
            'trace'
        ]
    }
});

require(['boot'], function () {
    require ([
        '../test/trace'
    ], function () {
        window.onload();
    });
});
