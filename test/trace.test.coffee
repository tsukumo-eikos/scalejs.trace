
define ['scalejs!core', 'scalejs!application'], ({log, trace}) ->

    # For deeper testing, pass to the console

    class ConsoleTesting
        constructor: () ->
            log.log 'core.trace: ', trace

            log.info 'this is a test', 'with multiple args', trace

            trace.options.color = false

            trace.info 'this is a test', 'which should not have color', trace

            trace.options.level = 1

            trace.options.color = true

            log.info 'this should not be seen'
            log.error 'this should be seen'

            trace.options.level = 9

            for key, func of trace
                if typeof func is 'function'
                    func 'testing', key

    new ConsoleTesting()

    describe 'core.trace', () ->

        it 'is defined', () ->

            expect(trace).toBeDefined()

