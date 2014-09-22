
# global require

require ['scalejs!core', 'browser'], (core) ->

    browser = core.browser

    stack_info = switch
        when browser.chrome then () ->
            trace = new Error().stack.split('\n')[4]
            line = trace.split(':')
            line = line[line.length - 2]
            left_paren = trace.indexOf ' ('
            func = if left_paren < 1 then 'global' else
                trace.substring trace.indexOf('at ') + 3, left_paren
            func = func.substring func.lastIndexOf(' ') + 1
            file = trace.substring trace.lastIndexOf('/') + 1
            file = file.substring 0, file.indexOf ':'

            func: func
            file: file
            line: line

        when browser.safari then () ->
            trace = new Error().stack.split('\n')[3]
            line = trace.split(':')
            line = line[line.length - 2]
            func = trace.substring 0, trace.indexOf '@'
            file = trace.substring trace.lastIndexOf('/') + 1
            file = file.substring 0, file.indexOf ':'

            func: func
            file: file
            line: line

        when browser.firefox then () -> undefined
        when browser.msie then () -> undefined
        else () ->
            func: 'unknown'
            file: 'unsupported'
            line: -1



    LEVELS = [
        {
            name: 'SEVERE'
            color: '#C0392B'
            level: 0
        },
        {
            name: 'ERROR'
            color: '#E74C3C'
            level: 1
        },
        {
            name: 'WARN'
            color: '#F1C40F'
            level: 2
        },
        {
            name: 'INFO'
            color: '#3498DB'
            level: 3
        },
        {
            name: 'SYSTEM'
            color: '#9B59B6'
            level: 4
        },
        {
            name: 'DEBUG'
            color: '#27AE60'
            level: 5
        }
        {
            name: 'NOTE'
            color: '#95A5A6'
            level: 5
        },
        {
            name: 'TODO'
            color: '#2ECC71'
            level: 6
        },
        {
            name: 'XXX'
            color: '#1ABC9C'
            level: 6
        },
        {
            name: 'TEXT'
            color: '#34495E'
            level: 7
        },
        {
            name: 'TRACE'
            color: '#BDC3C7'
            level: 8
        }
    ]

    ensure_length = (str, size) ->
        if str.length < size
            return str + new Array(size - str.length + 1).join ' '
        str.substring 0, size

    self =
        LEVELS: LEVELS
        options:
            level: 4
            color: true
            lengths:
                file: 15
                func: 15
                line: 3
            filter: (level, file, func, line, msg) ->
                # Preprocess objects
                objects = [ ]
                for item, i in msg
                    if typeof item is 'object'
                        objects.push item
                        msg[i] = '%o'

                msg = msg.join ' '
                objects.unshift ensure_length(level.name, 6) +
                    ' @' + ensure_length(file, self.options.lengths.file) +
                    ' [' + ensure_length(func, self.options.lengths.func) +
                    '](' + ensure_length(line, self.options.lengths.line) +
                    ') ' + msg

                return objects


    internal_trace_log = Function.prototype.call.bind console['log'], console

    trace_log = (level, msg) ->
        return if self.options.level < level.level
        msg = Array.prototype.slice.call msg
        info = stack_info()
        output = self.options.filter level, info.file, info.func, info.line, msg
        if self.options.color
            output[0] = '%c' + output[0]
            output.splice 1, 0, 'color:' + level.color

        internal_trace_log.apply console, output

    for level in LEVELS
        lower = level.name.toLowerCase()

        core.log[lower] = console[lower] = self[lower] =
            (( level ) -> () ->
                trace_log level, arguments
            )(level)

    # Override console
    console['log'] = self.text
    # Override core logging
    core.log.log = self.text

    core.registerExtension

        trace: self

