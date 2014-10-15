
# global require

define ['module', 'scalejs!core', 'browser'], (module, core) ->

    browser = core.browser

    _format = ( string = '', data ) ->
        return string.replace /{([\da-z_]*)}/gi, ( match, name ) ->
            if data[name]? then data[name] else match

    rgb = ( color ) ->
        if color.indexOf('rgb') is 0
            color = color.match /([0-9]+)(?=[,])/g
            return {
                r: color[0]
                g: color[1]
                b: color[2]
            }
        else
            if color.indexOf('#') is 0
                color = color.substring 1
            return {
                r: parseInt color.substring(0, 2), 16
                g: parseInt color.substring(2, 4), 16
                b: parseInt color.substring(4, 6), 16
            }

    uriColor = ( data, hex, fulfill, reject) ->
        img = new Image()

        img.onload = ( ) ->
            canvas = document.createElement 'canvas'

            if not canvas.getContext or not canvas.getContext '2d' or
            img.height < 1 or img.width < 1
                reject()

            canvas.width = img.width
            canvas.height = img.height

            ctx = canvas.getContext '2d'
            ctx.drawImage img, 0, 0

            imgd = ctx.getImageData 0, 0, canvas.width, canvas.height
            d = imgd.data

            to = rgb hex
            x = 0
            while x < d.length
                if  d[x] is 0 and d[x + 1] is 0 and
                d[x + 2] is 0 and d[x + 3] isnt 0
                    d[x] = to.r
                    d[x + 1] = to.g
                    d[x + 2] = to.b

                x += 4

            ctx.putImageData imgd, 0, 0

            fulfill canvas.toDataURL()

        img.src = data


    stack_info = switch
        when browser.chrome then () ->
            trace = new Error().stack.split('\n')[4]
            line = trace.split(':')
            line = line[line.length - 2]
            left_paren = trace.indexOf ' ('
            if left_paren > -1
                func = trace.substring trace.indexOf('at ') + 3, left_paren
                func = func.substring func.lastIndexOf(' ') + 1
            else
                func = 'global'
            slash = trace.indexOf '/'
            if slash > -1
                file = trace.substring trace.lastIndexOf('/') + 1
                file = file.substring 0, file.indexOf ':'
            else
                file = 'console'

            func: func
            file: file
            line: line

        when browser.safari or browser.firefox then () ->
            trace = new Error().stack.split('\n')[3]
            line = trace.split(':')
            line = line[line.length - 2]
            func = trace.substring 0, trace.indexOf '@'
            file = trace.substring trace.lastIndexOf('/') + 1
            file = file.substring 0, file.indexOf ':'

            func: func
            file: file
            line: line

        when browser.msie then () ->
            func: 'unknown'
            file: 'not implemented'
            line: -1
        else () ->
            func: 'unknown'
            file: 'unsupported'
            line: -1

    # coffeelint: disable=max_line_length
    LEVELS = {
        'SEVERE': {
            color: '#C0392B'
            level: 0
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAldJREFUWAm9l7svREEYxZd4hIhIbEGv0KxaKdGQiNofoNCIVkGvUqgUEtGtgkKBxCMKCY2/QC90JOKVeJzf7s41d+a+9rrrJCcz880353z77dx1lUp1dGm4FTfEabFHLBpooo0HXngG6Nfs2+KL5ofiojgi5gVn0UALTdsDzwBuAXYi86zdcT+lq2OvawW0NUqgHe9BOcmTV21fiEcNaqi1lvZOiBSRBd1K+rATR7VYFq/FL9Gutog5mmjjgVcihrW7IB6LdCZvAZxFAy00E7Gm3SWx7GTxXc2JVfFJTCuGHHI5E7poWqONB14ethRBnO9lX5wVO0Qb3JUpcVO8E00xzImxR44NNNBCE23O4OVhVREjaMYHxdbFipddKnGBxxs0l9lOG9OCs2gYPTPi5YGWmYSo8Ub7PNOD3snfAHvkkBulYWJ4eagoYhKSRi7Wnjgj0l7InFjWC4uXh05F3sQkc3fvXvnQjSet8cArEleKJh0uYg+PAO3BrD65dNatWIY83ALOW+HoaCZ69CqZ3/oiWh2lgTYeAdwO8CfzLNgtfoI2HgHcAtjgcWoVMmkPyL3ZxzGq3W4MTbRDiOrAozIOQlnFLNBEO4SoAkiohrKKWTSl2SfPZ9FtY941Wmh6iOsAB7a97PwBtNBsCkPKzvICktYVNNDKhXmdSjNI20fjT9jR6TSTuH3O/hm8Yp2IcSZxcc64r2e5i+H3+7SJIsgN/ebndrYO8o8Ez3LcJzZxcshtCXj5XBE/RWNoRmLsRb2gKlwsJiXHq7gxZ07sX1GW226DzHPhB+oBhTC4qzBQAAAAAElFTkSuQmCC'
        },
        'ERROR': {
            color: '#E74C3C'
            level: 1
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAMRJREFUWAntldEOwyAIRdtl/y378k0ebmJsV7wI8UUTiw/AObFGj8MepaZ8nVPs9s8ZM3BIuyUi4G6JSDgtkQEflsiEmxIsvD++AIzEy8Fk4Qrpxwi4zRE08MAjBLSHnPVz1wxyT1Fr2+Hq82o7rFhvgb0DeweW78DMRRRybSzfgS3wnviRYY+RTEjMln7QoNSFPqfMRC0iU6u5gkLEUhdME9QhMrWCoj6yEgwUuX/hkMmUMOGZEsPwDAkaHinhhkdImPAfT2RuwuaH2RgAAAAASUVORK5CYII='
        },
        'WARN': {
            color: '#F39C12'
            level: 2
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAkpJREFUWAnFl7tOW1EQRYEIhEiACCqaNIgyjfkECn6Agg+gSGMqnlIe8j8kUur06UEUfAAFZRQhikTKg4chFJHSRGGv2CNtru+xHefey5aGmXNmz56ZA0YwNDQ4nqp0T7YvI64UE+p2JfvTNmLuKsOGOkXz8JtVdX+oRmc5A5zrjlzpYNPYOuu3yu7OhmwajQ8VY3Eu/RXYMJrhl9vmd6W9Attf2ADHigPEMQScR5Eo0m9bE5qtmjhxDICHWyjYyLc/1fmBdSDmLoYo/BV2TJwmz2RZcBcD4KkpBGx/KQvx74rHc5S5Ixc8aqj9b+xKIUTxnEFNdtA2YpDitrIDfM1ufyON6bZOUz4GIwbk4MQ9rzApS2IkmWkl6nKzxnmrmAZgtOXuxOTgBKhFYyAweVMW2/xSPGdKHyxHHIADN+rQQCsX3V6grooZq3qn+JudvyZiOHADaKzHoV/PxEweW/xWvJAppknkvSE0uNREHq0pWQdGOm5aF0zs27/X+STD/WJnj7mGS03gn16BSa9kMT1+MZTM141DnAU1roEm2j3xXAwv5LM+KKh1rRe9hPK2X+pV1CVPrQ/Q8xWY0AuOuojXlGNDjDgFNFzzZYrIbzEmdPJKiqz7pnGJU0DDNa91jt+md2qYzIkfdU59SijsdwA00HLtVwg4mIjJnLTmhJy4328BpWi5dscrMJET+FyPyYoCWmh6D3r+Rd72ZfyTkf1z/oe6P2aChswnqzJuDKv5J9kT2X3gc7ef8soGmlen17Kfsqqen15vZPO3plMi6cExu04AAAAASUVORK5CYII='
        },
        'INFO': {
            color: '#3498DB'
            level: 3
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAYlJREFUWAnFlzFOwzAYhVsQQqyVOiAhZgQLp+AGvQoH4BZMiGsw9gBsdO3UCYkRITLA+9L8Veo61H8T7Ce92In9v/eUpok9HqVjqqk34nXTWh+FhfjW0PrvDAyBS4k8iT9OUkPtwThT5YP4JXrNbT61aKDlwpVmc0tNqG+LFppJuNWsD7GvaViPJtp/4lyjKzEsHuocbTyiONbVuZhqFoqk1uGB1w7udSVVhHkhPLV4beFCZ5+iR2RLwFmLF54bPKrnMe97B6jHs8ZExz7/dW9wm4/n5EiHmXgq5gaeMwLc5XZu+dXeS12w25K7XY5l/i2etFLt61ITA+G9qBDzFg4ZYMQz4IX9TN666HwCVNGRPBcrAvCBKIUVAV5LueNNgJeCAWrvQ1/FYW57OFPbzauYlcpzqJbhHE+8axT/HJMidUGyjtx9TPkJdhYkyKUuybqt1yP7Aswbr6hO0UWpJSq6LLcQRTcmFqLo1sxC0P7r5rTr294OYP2pOrYlp7U+4wuR/R+0ftL2/BfozNBvModPTAAAAABJRU5ErkJggg=='
        },
        'SYSTEM': {
            color: '#9B59B6'
            level: 4
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAoNJREFUWAnll7FLW1EYxbUgiLjq2qBLQR3tZpd2dLIOrgWhUKfOgls3oX+A/g1O/QtacKiDg5ZOlaeUQtvUSUoLEnt+L98JNy/RvKgvGXrg+N177ne+774kN96MjPzvGC35Akwqb06cFxeCjMGxeBRk/Em8EO8FNN4UKXhVkuTiwXsnrMr9TSw2PpW2nuiMz5K58/FSo2+MybErutC+xr9ifqg4JQKvM0ZjDY1cPF6nFjVL4YGy9kTMv8VX4suYf1WcFg038Jw1ctDx4KUGc2pSuyfeKAPDubgoTojfRbQVMQUaTPFcEzQ8eKlBLTRq34hnWm2Il+LTyOQpMH8WiycGHaYgh1z0jVigFjWpTY+uYLeZiPG1aBxogPbCQhLRYRHkouM1qImWifTqAMfGBauO9GrDuGZ1serGrk8verawphGLWUtpDrYV0LcKuqcu6Hka8bBOjRSZJuj0zMHRWI7xh4gOD2PwxUIf0Z5awfM+5u6Zn83HIXrRnloMTiz0Ee3xQ9jqh3TPXP+rv7wsj5wV8UfofMF0Ax7YDXhY+1lYpAc6PXNwbq8rEimVBXqX+3qsbAtRuMq3gLcxRcdbwCk4jYylNDPRZwt6mak9rm2Pe7R0NvAxVp84K2IWcaagl5na4xr2uId75p+Bd7Hq3TnZu/TTWC8T7XENe9zDPXOdr8W6yGkYBOlFzxy8BX/Et83pQP7Si55tmNAsE3kFhvLvWH3zy0JDcSgXEjYAbrqScd1K4c9LqnFtQ7/VlYxCfCaGeillE1yhd0Q/4UCv5WzAuO6HyZkS1kVvkDHn3XPHW/8wUa0WJjXiDnchunCvSC4evD0x2jOjmUCxOXFevNcfp/8A6uxI68d+lSQAAAAASUVORK5CYII='
        },
        'DEBUG': {
            color: '#27AE60'
            level: 5
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAjhJREFUWAnFl7tO3EAUhhdQSmokJBKogIqGB5iCNmnS0gMPxAsgJCh4BArTkYoK0UTpcilTRaLg8n/mHK89O+M1xia/dObMuf6HGe96mUym2JhuW3fLin6RHEu+m7DHR6wLZri+qepJsjWn+pPifyyX/FiIkdMGOKiDc7LIIvx4UZNgOqU+yHkhWUkFzUeMHHJzCBYoOX2AwpweNLOhDmTtNjxpgxxycwgWKOoJmzI4lt91Z7S/sZz42FM2uTnAQQ2cDfySRSD3HNxbPEUY+8hNwe8frhJ+BRhXL67sc/DX4l1ULjdYsXNVDyH+woJBmsFiubN4F0VuXI8drLgw3VD+HMTHOYY9c/8+yU9tHiJ56wBxPzg6Y1WZ3GffIailR2+cqLIvudfRoxfWVcXxeaO+mh70SoInM4d9BdriubrYTw96JdFGsJes6Ofs1Ys3W99jj+volcSCvCT/N7RdwbsMxQCcQkqqF8YAk9ArxbHQdgK3AxB7i2yvtgEuvXoA3bkXx8RQyLpkyC8i7wtHFv5rJf4YDWnDkYT/WoGs/gZ7K3mqF1wl6s9AMN+59FJNPmv/aLHXKGqorfeiNwjlGi0E+WsPIj/mV8k/SdfTIJeaGPSmhw/SiPv9bza8U2Nb22vJvCHIITcFelMPVwNbsgjM+/LhynYkR5JTCf9cIOzxEatfq8wZwAEXnBUOtcN5VnnG28ABF5zVtAFDKMp13MU5AjR+XB8xhKJcx12cwzkrtrVqN/6m4noGLwc6AMU1QccAAAAASUVORK5CYII='
        },
        'NOTE': {
            color: '#95A5A6'
            level: 5
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAe9JREFUWAntVDFOw0AQNBINVNAgXgCipaWwPwA9nwAJHuBroOIJ0KaghT4p6OADVBEtBRINEgIpzFi30nLZuzj2JRISK43vvJ6d2VzsLYo8UUNmYsDlkU+r/ClzNpvtVOb95ZrfuwktNsGvEsSEQ36MB6nZEYr9m7vIoYUnFeNFyn+nQ7Fcx07dmbFIc/6QZCzaPNnAMsyjDezgXPhQY4z7o8h51QHXteRR34wzZMX8E/sLYN1kFkUf82gDQ9/AO9bdiDHTfc2dpb2B5BfA7m4sgs8txJzaxwDNiQqwokRSOFydRUKuBjRP9jF+IzPwRS9YV5rM9GXoORR004+bTI2rGOo1xm+KVnF984WXTWb6UvrnI6wVYEUncwqJODves5SRo3gVecZ0Z3MWXwE0f+JNhzhEDetDuLZaz774tG2B4q1hP/b1ugGnOMmtTL9vsLaSTPshh5U25t7ZVDurp98tKNs2zcxyWHFi6gacyUwkh4HAK+4PEnx+oiVwDXBi9jLX008LfUB4H9DBr4PHzTmhubJ3yM8devqJkKyPUOM7cQJwL3lZObZHwDnA96hTDFAlgtbKF1PnOaxYw8Y3gV6hp582Cff8RDknKoA12aKEUmjG+yxH26ZLmX40zXq0bcz5Kd0BPN574AHg/720+AHGRUFCBMvPGwAAAABJRU5ErkJggg=='
        },
        'TODO': {
            color: '#2ECC71'
            level: 6
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAHpJREFUWAntVdEKACEIs7j//+W7eu1BaQoDb0EPYYnNbQ4ze9f21vCC2djMJsi+f4AEEWJXKekIqACEA6WqoLfgirG63BKBzejI2UpZf6JIVwHiAxFi5yfdMx0BFYBwoFQV9Ba4DFXwFwhoFiA+oFlQKg66EyIc6DULPqi2BjrQLISlAAAAAElFTkSuQmCC'
        },
        'XXX': {
            color: '#1ABC9C'
            level: 6
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAMxJREFUWAljYBgFmCHwHyhES3wEaL4VzFpGGAOJBllOa/ANaAE3yBJ8DkCXo7bDwOYz0dqrhMwHOaAeiJHjHKYHJDYBxqEVDQoGQkELiwpC6kh14+CJgho8Tu/DI0cVKVjwIhsGC2p0OZg4slpK2IMnCuqB3gD5DoZhvgLxR3MBLDRoRoMKotFcQLPgJcbg0bpgUFTHo7mAmMRKMzWjuWA0F6C3ekCJDdQOAAF0OZg4RJZycnC0iFjweITaPka26gOMMxCJ8BDQcmeYAwAiO0hhDc768wAAAABJRU5ErkJggg=='
        },
        'TEXT': {
            color: '#34495E'
            level: 7
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAF1JREFUWAntlDEOACAIxND//1nlBTDYOFjmC5DSEGFJ4HcC4wBYLyHMl8OdnQRIB7J3WTpQIqIDpAOt3XWghYkMkQ74B8jL3etNOtDa0j/QwkSGSAf8A+Tl7H2PwAbJ0gYQVt5RuAAAAABJRU5ErkJggg=='
        },
        'TRACE': {
            color: '#BDC3C7'
            level: 8
            icon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAXVJREFUWAntVqFyQjEQhA4GicWjUa3A8xP11XwC/QN8fX+ivgZEPR5bWdOZ0l1KmCO5vLuQuL6buXnJ5XZvuZeXMBj01negvgNTUBzPfiiluysFKPn3IrYVY9ewhYAHUWknxq5hCwGyA8UCLJVrJIT3y+dzBBhi/gnn2g98ArcwSPGZh2gGKhan7wWtByvS06GX4BHQIOA1ovFyRLCyFm6EgFXCVMZ1gpeqfhcCFooAhtyc7sRzoRGeX/Aj/Bs+hufM5DYTFOY5YixO/1DW41C2RnYhZojmT5gHAS/RWm6a1Ko5iJoeQImy3E8QcbY9dICvwzKzhpkgKnDDceNRADciN2SXubm9ifzkWJzOT7HLvJwXDg9ghewgYHNBpgMPV4pCxALy2A0CeBxrZnFomKtYF8EemUHA7Ar1N+nCKun5kEbEK5dXLwXwKuaVLE3DyPXq8RIMLE5/q2W75SBqegDVCij+E1rbMeIP8PAKpi0Ie47/3YFfWO+zWrE8lLIAAAAASUVORK5CYII='
        }
    }
    # coffeelint: enable=max_line_length


    ensure_length = (str, size) ->
        if str.length < size
            return str + new Array(size - str.length + 1).join ' '
        str.substring 0, size

    longest_level = 6

    self =
        levels: LEVELS
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
                objects.unshift ensure_length(level.name, longest_level) +
                    ' @' + ensure_length(file, self.options.lengths.file) +
                    ' [' + ensure_length(func, self.options.lengths.func) +
                    '](' + ensure_length(line, self.options.lengths.line) +
                    ') ' + msg

                return objects
        isLoaded: false
        loaded: ( ) ->
            self.isLoaded = true
            console.system 'trace logging enabled'


    config = module.config()
    core.object.merge self, config

    expected_load_count = 0

    for level, settings of self.levels
        if settings.icon and settings.color
            expected_load_count++
            uriColor settings.icon, settings.color, (( settings ) -> ( icon ) ->
                settings.coloricon = icon
                loaded()
            )(settings), ( (settings) -> ( ) ->
                settings.coloricon = settings.icon
                loaded()
            )(settings)

        if level.length + 1 > longest_level
            longest_level = level.length + 1

    load_count = 0
    loaded = () ->
        load_count++
        if load_count is expected_load_count
            build()

    # Store console function for later use
    internal_trace_log =
        Function.prototype.call.bind console['log'], console

    build = ( ) ->
        if not config.noConflict

            trace_log = (level, msg) ->
                return if (self.options.level < level.level and
                not level.enabled) or level.disabled
                # Parse arugments structure
                msg = Array.prototype.slice.call msg
                # Collect info from the stack
                info = stack_info()
                # Filter the information
                output = self.options.filter level,
                info.file, info.func, info.line, msg
                # Setup for styles in the console
                output[0] = '%c  %c ' + output[0]
                if self.options.color
                    output.splice 1, 0, 'color:' + level.color + ';'
                    icon = level.coloricon
                else
                    output.splice 1, 0, ''
                    icon = level.icon
                bg = 'background:url(' + icon +
                    ');background-size:13px'
                if browser.firefox
                    bg += ';padding-bottom:1px'
                output.splice 1, 0, bg
                # Finally log the parsed info
                internal_trace_log.apply console, output

            # Setup log levels
            for level, settings of self.levels
                settings.name = level.toUpperCase()
                lower = level.toLowerCase()

                core.log[lower] = console[lower] = self[lower] =
                    (( settings ) -> () ->
                        trace_log settings, arguments
                    )( settings )

            # Override console
            console['log'] = self.text
            # Override core logging
            core.log.log = self.text

        else # NO CONFLICT

            for level, settings of self.levels
                name = level.toLowerCase()

                if settings.enabled or settings.level < self.options.level
                    prefix = '%c  %c ' +
                        ensure_length level.toUpperCase(), longest_level
                    if self.options.color
                        icon = settings.coloricon
                        color = 'color:' + settings.color
                    else
                        icon = settings.icon
                        color = ''
                    icon = 'background:url(' + icon + ');background-size:13px'
                    if browser.firefox
                        icon += ';padding-bottom:1px'

                    core.log[name] = console[name] = self[name] =
                        Function.prototype.bind.call internal_trace_log,
                            console, prefix, icon, color

                    if name is 'text'
                        core.log['log'] = console['log'] = self['log'] =
                            Function.prototype.bind.call internal_trace_log,
                                console, prefix, icon, color
                else
                    core.log[name] = console[name] = self[name] = ( ) ->
                        undefined
        self.loaded()

    # Register self as trace extension
    core.registerExtension

        trace: self

