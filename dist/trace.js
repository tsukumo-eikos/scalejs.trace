define('trace',['module', 'scalejs!core', 'browser'], function(module, core) {
  var LEVELS, browser, build, config, internal_trace_log, level, longest_level, self, settings, stack_info, uriColor, _ensure_length, _format, _ref;
  _ensure_length = function(str, size) {
    var abs;
    size = Number(size);
    if (!isFinite(size) || size === 0) {
      return str;
    }
    abs = Math.abs(size);
    if (str.length < abs) {
      if (size > 0) {
        return str + new Array(abs - str.length + 1).join(' ');
      } else {
        return new Array(abs - str.length + 1).join(' ') + str;
      }
    }
    return str.substring(0, size);
  };
  _format = function(string, data) {
    if (string == null) {
      string = '';
    }
    return string.replace(/{([\da-z_]+)}(?:\((-?[\d]+| )\))?/gi, function(match, name, space) {
      var word;
      word = data[name] != null ? data[name] : match;
      if (space) {
        word = _ensure_length(word, space);
      }
      return word;
    });
  };
  uriColor = function(data, hex) {
    var match;
    match = data.match(/^data:.+\/(.+);(.+),(.*)$/);
    if (match[1] === 'svg+xml' && match[2] === 'base64') {
      data = atob(match[3]);
      data = data.replace(/path /, function() {
        return 'path fill="' + hex + '" ';
      });
      data = 'data:image/svg+xml;base64,' + btoa(data);
    }
    return data;
  };
  browser = core.browser;
  stack_info = (function() {
    switch (false) {
      case !browser.chrome:
        return function() {
          var file, func, left_paren, line, slash, trace;
          trace = new Error().stack.split('\n')[4];
          line = trace.split(':');
          line = line[line.length - 2];
          left_paren = trace.indexOf(' (');
          if (left_paren > -1) {
            func = trace.substring(trace.indexOf('at ') + 3, left_paren);
            func = func.substring(func.lastIndexOf(' ') + 1);
          } else {
            func = 'global';
          }
          slash = trace.indexOf('/');
          if (slash > -1) {
            file = trace.substring(trace.lastIndexOf('/') + 1);
            file = file.substring(0, file.indexOf(':'));
          } else {
            file = 'console';
          }
          return {
            func: func,
            file: file,
            line: line
          };
        };
      case !(browser.safari || browser.firefox):
        return function() {
          var file, func, line, trace;
          trace = new Error().stack.split('\n')[3];
          line = trace.split(':');
          line = line[line.length - 2];
          func = trace.substring(0, trace.indexOf('@'));
          file = trace.substring(trace.lastIndexOf('/') + 1);
          file = file.substring(0, file.indexOf(':'));
          return {
            func: func,
            file: file,
            line: line
          };
        };
      case !browser.msie:
        return function() {
          return {
            func: 'unknown',
            file: 'not implemented',
            line: -1
          };
        };
      default:
        return function() {
          return {
            func: 'unknown',
            file: 'unsupported',
            line: -1
          };
        };
    }
  })();
  LEVELS = {
    'SEVERE': {
      color: '#C0392B',
      level: 0,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMzAgMEwxNiA0IDIgMHMtLjE0IDEuNjE2IDAgNGwxNCA0LjM3OEwzMCA0Yy4xNC0yLjM4NCAwLTQgMC00ek0yLjI1NiA2LjA5N0MzLjAwNiAxMy45MyA1LjgwMyAyNy4xMDQgMTYgMzJjMTAuMTk3LTQuODk2IDEyLjk5NS0xOC4wNyAxMy43NDQtMjUuOTAzTDE2IDExLjI2NCAyLjI1NiA2LjA5N3oiLz48L3N2Zz4='
    },
    'ERROR': {
      color: '#E74C3C',
      level: 1,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMzIgMjNMMjMgMEg5TDAgOXYxNGw5IDloMTRsOS05VjlsLTktOXptLTE0IDNoLTR2LTRoNHY0em0wLThoLTRWNmg0djEyeiIvPjwvc3ZnPg=='
    },
    'WARN': {
      color: '#F39C12',
      level: 2,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMTYgNC45Nkw1LjIyNCAyOGgyMS41NTJMMTYgNC45NnpNMTYgMGMuNjkgMCAxLjM4LjQ2NSAxLjkwMyAxLjM5NWwxMy42NiAyNy4yMjJjMS4wNDYgMS44Ni4xNTUgMy4zODMtMS45OCAzLjM4M0gyLjQyQy4yODMgMzItLjYwNyAzMC40NzguNDQgMjguNjE3TDE0LjEgMS4zOTVDMTQuNjIuNDY1IDE1LjMxIDAgMTYgMHptLTIgMjRjMC0xLjEwNS44OTUtMiAyLTJzMiAuODk1IDIgMi0uODk1IDItMiAyLTItLjg5NS0yLTJ6bTItMTJjMS4xMDUgMCAyIC44OTUgMiAybC0uNjI1IDZoLTIuNzVMMTQgMTRjMC0xLjEwNS44OTUtMiAyLTJ6Ii8+PC9zdmc+'
    },
    'INFO': {
      color: '#3498DB',
      level: 3,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMTYgMEM3LjE2MyAwIDAgNy4xNjMgMCAxNnM3LjE2MyAxNiAxNiAxNiAxNi03LjE2MyAxNi0xNlMyNC44MzcgMCAxNiAwem0tMiA2aDR2NGgtNFY2em02IDIwaC04di0yaDJ2LThoLTJ2LTJoNnYxMGgydjJ6Ii8+PC9zdmc+'
    },
    'SYSTEM': {
      color: '#9B59B6',
      level: 4,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMTUgMkM2LjcxNiAyIDAgOC43MTYgMCAxN3M2LjcxNiAxNSAxNSAxNWM4LjI4NCAwIDE1LTYuNzE2IDE1LTE1UzIzLjI4NCAyIDE1IDJ6bTguNDg3IDIwYy4yNjgtMS4yNjQuNDM3LTIuNjA2LjQ5Mi00aDMuOTgyYy0uMTA0IDEuMzgtLjQyNiAyLjcyMi0uOTYgNGgtMy41MTV6TTYuNTEzIDEyYy0uMjY4IDEuMjY0LS40MzcgMi42MDYtLjQ5MiA0SDIuMDRjLjEwNC0xLjM4LjQyNi0yLjcyMi45Ni00aDMuNTE1em0xNC45MjYgMGMuMyAxLjI4LjQ4IDIuNjIuNTQgNEgxNnYtNGg1LjQ0ek0xNiAxMFY0LjE0NmMuNDU2LjEzMy45MDguMzU1IDEuMzUuNjY4LjgzMi41ODYgMS42MjYgMS40ODggMi4zIDIuNjEuNDY0Ljc3NC44NjYgMS42MzcgMS4yMDIgMi41NzdIMTZ6bS01LjY1LTIuNTc4Yy42NzQtMS4xMiAxLjQ2OC0yLjAyMyAyLjMtMi42MS40NDItLjMxMi44OTQtLjUzNCAxLjM1LS42NjdWMTBIOS4xNDhjLjMzNi0uOTQuNzM4LTEuODA0IDEuMjAzLTIuNTh6TTE0IDEydjRIOC4wMmMuMDYtMS4zOC4yNC0yLjcyLjU0LTRIMTR6TTIuOTk3IDIyYy0uNTMzLTEuMjc4LS44NTQtMi42Mi0uOTYtNGgzLjk4NGMuMDU2IDEuMzk0LjIyNSAyLjczNi40OTMgNEgyLjk5N3ptNS4wMjQtNEgxNHY0SDguNTZjLS4zLTEuMjgtLjQ4LTIuNjItLjU0LTR6TTE0IDI0djUuODU0Yy0uNDU2LS4xMzMtLjkwOC0uMzU1LTEuMzUtLjY2OC0uODMyLS41ODYtMS42MjYtMS40ODgtMi4zLTIuNjEtLjQ2NC0uNzc0LS44NjYtMS42MzctMS4yMDItMi41NzdIMTR6bTUuNjUgMi41NzhjLS42NzQgMS4xMi0xLjQ2OCAyLjAyMy0yLjMgMi42MS0uNDQyLjMxLS44OTQuNTM0LTEuMzUuNjY3VjI0aDQuODUyYy0uMzM2Ljk0LS43MzggMS44MDMtMS4yMDMgMi41OHpNMTYgMjJ2LTRoNS45OGMtLjA2IDEuMzgtLjI0IDIuNzItLjU0IDRIMTZ6bTcuOTgtNmMtLjA1NS0xLjM5NC0uMjI0LTIuNzM2LS40OTItNGgzLjUxNmMuNTMzIDEuMjc4Ljg1NSAyLjYyLjk2IDRIMjMuOTh6bTEuOTc4LTZIMjIuOTZjLS41OC0xLjgzNi0xLjM4Ni0zLjQ0Ny0yLjM1My00LjczMiAxLjMzLjYzNiAyLjUzMyAxLjQ4OCAzLjU4NSAyLjU0LjY3LjY3IDEuMjYgMS40MDQgMS43NjYgMi4xOTJ6TTUuODA4IDcuODA4YzEuMDUyLTEuMDUyIDIuMjU2LTEuOTA0IDMuNTg1LTIuNTRDOC40MjYgNi41NTMgNy42MjMgOC4xNjQgNy4wNCAxMEg0LjA0Yy41MDQtLjc4OCAxLjA5NC0xLjUyIDEuNzY2LTIuMTkyek00LjA0MiAyNEg3LjA0Yy41ODIgMS44MzYgMS4zODYgMy40NDcgMi4zNTMgNC43MzItMS4zMy0uNjM2LTIuNTMzLTEuNDg4LTMuNTg1LTIuNTQtLjY3LS42Ny0xLjI2LTEuNDA0LTEuNzY2LTIuMTkyem0yMC4xNSAyLjE5MmMtMS4wNTIgMS4wNTItMi4yNTYgMS45MDQtMy41ODUgMi41NC45NjctMS4yODUgMS43Ny0yLjg5NiAyLjM1NC00LjczMmgyLjk5OGMtLjUwNC43ODgtMS4wOTQgMS41Mi0xLjc2NiAyLjE5MnoiLz48L3N2Zz4='
    },
    'DEBUG': {
      color: '#27AE60',
      level: 5,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMzIgMTh2LTJoLTYuMDRjLS4xODMtMi4yNy0uOTkzLTQuMzQ1LTIuMjQtNi4wMDhoNS4wNmwyLjE5LTguNzU4TDI5LjAzLjc1bC0xLjgxIDcuMjRoLTUuNDZsLS4wODQtLjA2M2MuMjEtLjYxLjMyNC0xLjI2My4zMjQtMS45NDRDMjIgMi42NzggMTkuMzE0IDAgMTYgMHMtNiAyLjY3OC02IDUuOTgzYzAgLjY4LjExNCAxLjMzNC4zMjQgMS45NDQtLjAyOC4wMi0uMDU2LjA0My0uMDg0LjA2NEg0Ljc4TDIuOTcuNzVsLTEuOTQuNDg0IDIuMTkgOC43NThoNS4wNkM3LjAzNCAxMS42NTUgNi4yMjQgMTMuNzI4IDYuMDQgMTZIMHYyaDYuMDQzYy4xMiAxLjQyNy40ODUgMi43NzUgMS4wNSAzLjk5MkgzLjIyTDEuMDMgMzAuNzVsMS45NC40ODQgMS44MS03LjI0M2gzLjUxMmMxLjgzNCAyLjQ0IDQuNjA2IDMuOTkzIDcuNzA4IDMuOTkzczUuODc0LTEuNTU0IDcuNzA4LTMuOTkyaDMuNTFsMS44MTIgNy4yNDQgMS45NC0uNDg1LTIuMTktOC43NThoLTMuODc0Yy41NjctMS4yMTcuOTMyLTIuNTY1IDEuMDUtMy45OTJIMzJ6Ii8+PC9zdmc+'
    },
    'NOTE': {
      color: '#95A5A6',
      level: 5,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMTIgMjBsNC0yTDMwIDRsLTItMi0xNCAxNC0yIDR6bS0yLjk2IDcuMDk3Yy0uOTg4LTIuMDg1LTIuMDUtMy4xNS00LjEzNi00LjEzN0w4IDE0LjQzNSAxMiAxMiAyNCAwaC02TDYgMTIgMCAzMmwyMC02IDEyLTEyVjhMMjAgMjBsLTIuNDM0IDR6Ii8+PC9zdmc+'
    },
    'TODO': {
      color: '#2ECC71',
      level: 6,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMTIgMmgyMHY0SDEyVjJ6bTAgMTJoMjB2NEgxMnYtNHptMCAxMmgyMHY0SDEydi00ek0wIDRjMC0yLjIxIDEuNzktNCA0LTRzNCAxLjc5IDQgNC0xLjc5IDQtNCA0LTQtMS43OS00LTR6bTAgMTJjMC0yLjIxIDEuNzktNCA0LTRzNCAxLjc5IDQgNC0xLjc5IDQtNCA0LTQtMS43OS00LTR6bTAgMTJjMC0yLjIxIDEuNzktNCA0LTRzNCAxLjc5IDQgNC0xLjc5IDQtNCA0LTQtMS43OS00LTR6Ii8+PC9zdmc+'
    },
    'XXX': {
      color: '#1ABC9C',
      level: 6,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMzIgMTBMMTYgMiAwIDEwbDE2IDggMTYtOHpNMTYgNC42NTVMMjYuNjkgMTAgMTYgMTUuMzQ1IDUuMzEgMTAgMTYgNC42NTV6bTEyLjc5NSA5Ljc0M0wzMiAxNmwtMTYgOC0xNi04IDMuMjA1LTEuNjAyTDE2IDIwLjc5NnptMCA2TDMyIDIybC0xNiA4LTE2LTggMy4yMDUtMS42MDJMMTYgMjYuNzk2eiIvPjwvc3ZnPg=='
    },
    'TEXT': {
      color: '#34495E',
      level: 7,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNMCA2aDMydjJIMHptMCA0aDIydjJIMHptMCA0aDMydjJIMHptMCA0aDIydjJIMHptMCA0aDMydjJIMHptMCA0aDIydjJIMHoiLz48L3N2Zz4='
    },
    'TRACE': {
      color: '#BDC3C7',
      level: 8,
      icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBkPSJNNCAxNmw4LThIOGwtOCA4IDggOGg0em0yMC04aC00bDggOC04IDhoNGw4LTh6bS03LTRsLTUgMjRoM2w1LTI0eiIvPjwvc3ZnPg=='
    }
  };
  longest_level = 7;
  self = {
    levels: LEVELS,
    options: {
      level: 4,
      color: true,
      format: '{LVL} @{FILE}(15) [{FUNC}(15)]({LINE}(3))',
      filter: function(level, file, func, line, msg) {
        var i, item, objects, _i, _len;
        objects = [];
        for (i = _i = 0, _len = msg.length; _i < _len; i = ++_i) {
          item = msg[i];
          if (typeof item === 'object') {
            objects.push(item);
            msg[i] = '%o';
          }
        }
        msg = msg.join(' ');
        objects.unshift(_format(self.options.format, {
          LVL: _ensure_length(level.name, longest_level),
          FILE: file,
          FUNC: func,
          LINE: line
        }) + ' ' + msg);
        return objects;
      }
    }
  };
  config = module.config();
  core.object.merge(self, config);
  internal_trace_log = Function.prototype.call.bind(console['log'], console);
  build = function() {
    var color, icon, level, lower, name, prefix, settings, trace_log, _ref, _ref1, _results;
    if (!config.noConflict) {
      trace_log = function(level, msg) {
        var bg, icon, info, output;
        if ((self.options.level < level.level && !level.enabled) || level.disabled) {
          return;
        }
        msg = Array.prototype.slice.call(msg);
        info = stack_info();
        output = self.options.filter(level, info.file, info.func, info.line, msg);
        output[0] = '%c  %c ' + output[0];
        if (self.options.color) {
          output.splice(1, 0, 'color:' + level.color + ';');
          icon = level.coloricon;
        } else {
          output.splice(1, 0, '');
          icon = level.icon;
        }
        bg = 'background:url(\'' + icon + '\');background-size:13px';
        if (browser.firefox) {
          bg += ';padding-bottom:1px';
        }
        output.splice(1, 0, bg);
        return internal_trace_log.apply(console, output);
      };
      _ref = self.levels;
      for (level in _ref) {
        settings = _ref[level];
        settings.name = level.toUpperCase();
        lower = level.toLowerCase();
        core.log[lower] = console[lower] = self[lower] = (function(settings) {
          return function() {
            return trace_log(settings, arguments);
          };
        })(settings);
      }
      console['log'] = self.text;
      return core.log.log = self.text;
    } else {
      _ref1 = self.levels;
      _results = [];
      for (level in _ref1) {
        settings = _ref1[level];
        name = level.toLowerCase();
        if (settings.enabled || settings.level < self.options.level) {
          prefix = '%c  %c ' + _ensure_length(level.toUpperCase(), longest_level);
          if (self.options.color) {
            icon = settings.coloricon;
            color = 'color:' + settings.color;
          } else {
            icon = settings.icon;
            color = '';
          }
          icon = 'background:url(\'' + icon + '\');background-size:13px';
          if (browser.firefox) {
            icon += ';padding-bottom:1px';
          }
          core.log[name] = console[name] = self[name] = Function.prototype.bind.call(internal_trace_log, console, prefix, icon, color);
          if (name === 'text') {
            _results.push(core.log['log'] = console['log'] = self['log'] = Function.prototype.bind.call(internal_trace_log, console, prefix, icon, color));
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(core.log[name] = console[name] = self[name] = function() {
            return void 0;
          });
        }
      }
      return _results;
    }
  };
  _ref = self.levels;
  for (level in _ref) {
    settings = _ref[level];
    if (settings.icon && settings.color) {
      settings.coloricon = uriColor(settings.icon, settings.color);
    }
    if (level.length + 1 > longest_level) {
      longest_level = level.length + 1;
    }
  }
  build();
  console.system('trace logging enabled');
  return core.registerExtension({
    trace: self
  });
});

