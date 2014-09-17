
define ['scalejs!core', 'scalejs!application'], ({trace}) ->

    # For deeper testing, pass to the console

    console.log 'core.trace: ', trace

    describe 'core.trace', () ->

        it 'is defined', () ->

            expect(trace).toBeDefined()

