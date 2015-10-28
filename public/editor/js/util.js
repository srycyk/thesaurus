(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  this.Config = {
    apiHost: ''
  };
  this.DefinitionApi = (function() {
    function _Class(options) {
      if (!options) {
        options = {};
      }
      this.setUrl(options['server']);
      this.setParams(options['params']);
      this.handlers(options['success'], options['error']);
      this.fetched = [];
      this.failed = [];
    }
    _Class.prototype.get = function(data) {
      var params;
      params = this.params(this.toParams(data));
      return $.ajax({
        url: this.url,
        data: params,
        dataType: 'json',
        success: __bind(function(definition) {
          return this.successful(definition);
        }, this),
        error: __bind(function(xhr, status, error, exception) {
          error || (error = 'Not available');
          return this.unsuccessful({
            error: error,
            name: params['word']
          });
        }, this)
      });
    };
    _Class.prototype.query = "/definitions/find.json";
    _Class.prototype.host = function(serverType) {
      if (serverType === 'remote') {
        return "http://thesaurus-lexdump.rhcloud.com";
      } else if (serverType === 'local') {
        return "http://localhost:3000";
      } else {
        return '';
      }
    };
    _Class.prototype.setUrl = function(serverType) {
      this.url = this.host(serverType) + this.query;
      return this;
    };
    _Class.prototype.handlers = function(onSuccess, onError) {
      if (!onError) {
        onError = onSuccess;
      }
      this.onSuccess = onSuccess;
      this.onError = onError;
      return this;
    };
    _Class.prototype.successful = function(definition) {
      this.keep(definition, this.fetched);
      return this.onSuccess(definition);
    };
    _Class.prototype.unsuccessful = function(errors) {
      this.keep(errors, this.failed);
      return this.onError(errors);
    };
    _Class.prototype.keep = function(receiver, list) {
      var name;
      name = receiver.name;
      if (!this.contains(list, name)) {
        return list.unshift(name);
      }
    };
    _Class.prototype.contains = function(list, value) {
      return $.inArray(value, list) >= 0;
    };
    _Class.prototype.clear = function() {
      this.setParams();
      return this;
    };
    _Class.prototype.setParams = function(params) {
      return this.parameters = params || {};
    };
    _Class.prototype.toParams = function(data) {
      if (data instanceof Object) {
        return data;
      } else {
        return {
          word: data || ''
        };
      }
    };
    _Class.prototype.params = function(params) {
      return this.merge(params, this.trimWord);
    };
    _Class.prototype.trimWord = function() {
      return {
        word: this.parameters['word'].trim()
      };
    };
    _Class.prototype.merge = function() {
      var params;
      params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return $.extend.apply($, [this.parameters].concat(__slice.call(params)));
    };
    return _Class;
  })();
  this.HtmlHelpers = {
    htmlRow: function(content, klass) {
      return React.DOM.div({
        className: "row " + klass
      }, React.DOM.div({
        className: "col-md-12"
      }, this.evaluate(content)));
    },
    evaluate: function(content) {
      var out;
      if (!content) {
        return;
      }
      if (content instanceof Array) {
        out = [];
        while (content.length > 0) {
          out.push(this.evaluate(content.shift()));
        }
        return out;
      } else if (content instanceof Function) {
        return content();
      } else {
        return content;
      }
    },
    icon: function(name) {
      return React.DOM.span({
        className: "glyphicon glyphicon-" + name
      });
    },
    div: function(content, klass) {
      if (content == null) {
        content = ' ';
      }
      if (klass == null) {
        klass = ' ';
      }
      return React.DOM.div({
        className: klass
      }, this.evaluate(content));
    },
    span: function(content) {
      if (content == null) {
        content = ' ';
      }
      return React.DOM.span(null, this.evaluate(content));
    },
    nbsp: "\u00a0",
    spacedOut: function(small) {
      return " " + this.nbsp + (small ? '' : ' ');
    },
    buttonClass: function(colour, size) {
      if (colour == null) {
        colour = 'default';
      }
      if (size == null) {
        size = 'sm';
      }
      return "btn btn-" + colour + " btn-" + size;
    },
    htmlClickButton: function(clickHandler, iconName, title, enabled, colour, size) {
      var atts;
      if (!colour) {
        colour = 'default';
      }
      if (!size) {
        size = 'sm';
      }
      atts = {
        type: 'button',
        className: this.buttonClass(colour, size),
        title: title,
        onClick: clickHandler
      };
      if (!enabled) {
        atts['disabled'] = 'disabled';
      }
      return React.DOM.button(atts, this.icon(iconName));
    },
    defaultModalId: 'modal-id',
    htmlModal: function(title, content, id) {
      id = id != null ? id : this.defaultModalId;
      return React.DOM.div({
        className: 'modal fade',
        id: id,
        tabIndex: -1,
        role: 'dialog'
      }, React.DOM.div({
        className: 'modal-dialog'
      }, React.DOM.div({
        className: 'modal-content'
      }, React.DOM.div({
        className: 'modal-header'
      }, React.DOM.button({
        "className": 'close',
        "data-dismiss": 'modal',
        "aria-hidden": "true"
      }, this.icon('remove')), React.DOM.h4({
        className: 'modal-title text-center'
      }, title)), React.DOM.div({
        className: 'modal-body'
      }, React.DOM.p(null, this.evaluate(content))), React.DOM.div({
        className: 'modal-footer'
      }, React.DOM.button({
        "className": this.buttonClass('primary', 'medium'),
        "data-dismiss": 'modal'
      }, 'Close')))));
    },
    htmlModalLink: function(content, className, id, title) {
      id = id != null ? id : this.defaultModalId;
      if (title == null) {
        title = '';
      }
      return React.DOM.a({
        "href": "#" + id,
        "className": className,
        "data-toggle": 'modal',
        title: title
      }, this.evaluate(content));
    },
    htmlTableHead: function(headings, numCols) {
      var colspan;
      if ($.isArray(headings)) {
        colspan = 1;
      } else {
        headings = [headings];
        colspan = numCols || 1;
      }
      return React.DOM.thead(null, React.DOM.tr(null, headings.map(function(heading) {
        return React.DOM.th({
          colSpan: colspan
        }, heading);
      })));
    },
    htmlTableBody: function(rows) {
      return React.DOM.tbody(null, rows.map(__bind(function(row) {
        return React.DOM.tr(null, row.map(__bind(function(cell) {
          return React.DOM.td(null, this.evaluate(cell));
        }, this)));
      }, this)));
    },
    htmlTableFoot: function(content, columnCount) {
      if (content == null) {
        content = ' ';
      }
      return React.DOM.tfoot(null, React.DOM.tr(null, React.DOM.td({
        colSpan: columnCount
      }, this.evaluate(content))));
    },
    htmlTable: function(headings, rows, foot, classes) {
      var columnCount;
      if (classes == null) {
        classes = 'table-condensed';
      }
      columnCount = this.columnCount(rows);
      return React.DOM.table({
        className: "table " + classes
      }, this.htmlTableHead(headings, columnCount), this.htmlTableBody(rows), this.htmlTableFoot(foot, columnCount));
    },
    columnCount: function(rows) {
      if (rows.length === 0) {
        return 0;
      } else {
        return rows[0].length;
      }
    },
    take: function(array, size) {
      var row, rows;
      array = array.slice();
      rows = [];
      while (array.length > 0) {
        row = array.splice(0, size);
        while (row.length < size) {
          row.push(this.spacedOut());
        }
        rows.push(row);
      }
      return rows;
    }
  };
  this.Logger = {
    on: true,
    log: function(name, value) {
      if (!this.on) {
        return;
      }
      return this.logger(name, value);
    },
    logger: function(name, value) {
      if (value instanceof Object) {
        console.log("= > " + name + ":");
        console.log(this.show(value));
        return console.log("=========================");
      } else {
        return console.log(this.show_pair(name, value));
      }
    },
    show: function(object, level, out) {
      if (!level) {
        level = 0;
      }
      if (!out) {
        out = '';
      }
      out += "" + (this.margin(level)) + object + "\n";
      out += this.attributes(object, level + 1).join("\n");
      if (object.prototype) {
        return show(object.prototype, level + 1, out);
      }
      return out;
    },
    attributes: function(object, level) {
      return $.map(object, __bind(function(value, name) {
        return this.show_pair(name, value, level);
      }, this));
    },
    show_pair: function(name, value, level) {
      if (!level) {
        level = 0;
      }
      return "" + (this.margin(level)) + name + ": " + value;
    },
    margin: function(level) {
      var out;
      out = '';
      while (level--) {
        out += '  ';
      }
      return out;
    },
    logAjaxError: function(xhr, status, error, exception) {
      this.logger('xhr', xhr);
      this.logger('xhr.responseText', xhr.responseText);
      this.logger('status', status);
      this.logger('error', error);
      return this.logger('exception', exception);
    }
  };
  this.TextHelpers = {
    title: function(phrase) {
      if (phrase) {
        return phrase[0].toUpperCase() + phrase.slice(1);
      } else {
        return '';
      }
    },
    extractPhrase: function(text, start, finish, maxWords) {
      var selected;
      maxWords || (maxWords = 4);
      if (this.isWholeWord(text, start, finish)) {
        selected = text.slice(start, finish);
        if (selected.split(' ').length <= maxWords) {
          return selected;
        }
      }
      return null;
    },
    isWholeWord: function(text, start, finish) {
      if (!finish || start === finish) {
        return false;
      } else if ((start === 0 || this.isSpacey(text.charAt(start - 1))) && (finish === text.length || this.isSpacey(text.charAt(finish)))) {
        return true;
      } else {
        return false;
      }
    },
    isSpacey: function(s) {
      return s.match(/^[/.\-,:;?!()'"\s]+$/);
    }
  };
  this.TextSelection = (function() {
    function _Class(text, starts, word) {
      this.set(text, starts, word);
      this.changes = [];
      this.history = [];
    }
    _Class.prototype.set = function(text, starts, word) {
      this.setText(text);
      return this.setSelection(starts, word);
    };
    _Class.prototype.setText = function(text) {
      var dirty;
      text || (text = '');
      if (dirty = this.dirty(text)) {
        this.clear();
        this.text = text;
      }
      return dirty;
    };
    _Class.prototype.setSelection = function(starts, word) {
      this.starts = starts || starts === 0 ? starts : -1;
      this.word = word || '';
      this.keep(this.word);
      return this;
    };
    _Class.prototype.keep = function(word) {
      if (word && word.length > 0) {
        if ($.inArray(word, this.history) <= 0) {
          return this.history.unshift(word);
        }
      }
    };
    _Class.prototype.swap = function(word) {
      if (!this.hasSelection()) {
        return;
      }
      if (this.addChange(word)) {
        return this.replace(word);
      }
    };
    _Class.prototype.undo = function() {
      var newWord, oldWord, starts, _ref;
      if (!this.changes.length) {
        return;
      }
      _ref = this.lastChange(), starts = _ref[0], oldWord = _ref[1], newWord = _ref[2];
      this.starts = starts;
      return this.replace(oldWord, newWord.length);
    };
    _Class.prototype.clear = function() {
      this.changes = [];
      return this.setSelection();
    };
    _Class.prototype.hasChanges = function() {
      return this.changes.length;
    };
    _Class.prototype.hasSelection = function() {
      return this.starts >= 0;
    };
    _Class.prototype.hasText = function() {
      return this.text && !this.text.match(/^\s*$/);
    };
    _Class.prototype.recentChange = function() {
      if (!this.hasChanges()) {
        return null;
      }
      return this.changes[0];
    };
    _Class.prototype.addChange = function(newWord) {
      var lastChange;
      lastChange = this.changes[0];
      if (!lastChange || lastChange[2] !== newWord) {
        this.changes.unshift([this.starts, this.word, newWord]);
        return true;
      } else {
        return false;
      }
    };
    _Class.prototype.dirty = function(text) {
      return text !== this.text;
    };
    _Class.prototype.lastChange = function() {
      return this.changes.shift();
    };
    _Class.prototype.replace = function(word, offset) {
      this.text = this.before() + word + this.after(offset);
      this.word = word;
      return this;
    };
    _Class.prototype.before = function() {
      return this.text.slice(0, this.starts);
    };
    _Class.prototype.after = function(offset) {
      offset = offset != null ? offset : this.word.length;
      return this.text.slice(this.starts + offset);
    };
    _Class.prototype.toString = function() {
      return this.text;
    };
    _Class.prototype.show = function(word, starts) {
      if (!word) {
        word = this.word;
      }
      return word + this.position(starts);
    };
    _Class.prototype.position = function(starts, verbose) {
      var totalSize;
      if (starts == null) {
        starts = this.starts;
      }
      if (verbose) {
        totalSize = " of " + this.text.length;
      } else {
        totalSize = "";
      }
      if (starts < 0) {
        return '';
      } else {
        return "at " + starts + totalSize;
      }
    };
    _Class.prototype.info = function() {
      return ("" + (this.show()) + " word(" + this.word.length + ") text(" + this.text.length + ") ") + ("changes(" + this.changes.length + ") change(" + (this.changed()) + ")");
    };
    _Class.prototype.changeCount = function() {
      var plural;
      plural = this.changes.length === 1 ? '' : 's';
      return "" + this.changes.length + " change" + plural;
    };
    _Class.prototype.allChanges = function(sep) {
      var edits, index, out;
      sep = sep != null ? sep : ', ';
      out = '';
      index = 0;
      while (edits = this.changed(index)) {
        if (index++) {
          out += sep;
        }
        out += edits;
      }
      return out;
    };
    _Class.prototype.changed = function(index, infix) {
      var newWord, oldWord, starts, _ref;
      if (!index) {
        index = 0;
      }
      if (infix == null) {
        infix = 'from';
      }
      if (index >= this.changes.length) {
        return '';
      }
      _ref = this.changes[index], starts = _ref[0], oldWord = _ref[1], newWord = _ref[2];
      return "" + newWord + " " + infix + " " + oldWord;
    };
    return _Class;
  })();
}).call(this);
