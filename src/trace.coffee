
# global require

require ['scalejs!core', 'browser'], (core) ->

    browser = core.browser

    core.registerExtension

        trace: browser
