(function() {
  var initial;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  this.HelpText = {
    introTitle: 'Express Yourself More Clearly',
    introOpening: "For polished word selection",
    introParagraphs: ["A button-based editor where you can substitute your own (possibly misplaced) word, or phrase, with one from a whole slew of words that are offered as (more accurate) suggestions.", "Simply copy in some of your own text and highlight a particular word within it. Then you'll see a list of related words. Click one of these, and it'll replace the highlighted word inside your text.", "If you don't spot the right word at once you can widen the search in various ways.", "It's okay to learn by experimenting as all changes can be undone - for so long as you don't manually alter your text!", "Nearly all of the buttons and titles will try to explain themselves if you let the mouse hover over them."],
    introLead: function() {
      return this.opening(this.introOpening);
    },
    introLines: function() {
      return this.mapParagraphs(this.introParagraphs);
    },
    introText: function() {
      return [this.introLead(), this.introLines()];
    },
    opening: function(openingText) {
      return React.DOM.p({
        className: 'lead text-muted'
      }, openingText);
    },
    mapParagraphs: function(paragraphs) {
      return paragraphs.map(function(paragraph, index) {
        return React.DOM.p({
          key: index
        }, paragraph);
      });
    }
  };
  this.InputText = React.createClass({
    mixins: [Logger, HtmlHelpers, TextHelpers],
    getDefaultProps: function() {},
    componentDidMount: function() {
      return this.focus();
    },
    xshowRelatedWords: function(word) {
      if (!word) {
        return;
      }
      return this.getDefinition(word, this.props.addRelatedWords);
    },
    onSubmit: function(e) {
      var givenNode;
      e.preventDefault();
      givenNode = ReactDOM.findDOMNode(refs.input_word);
      return findListOfRelatedWords(givenNode.value.split(/\s+/));
    },
    findListOfRelatedWords: function(words) {
      return $.each(words, __bind(function(_, word) {
        return this.showRelatedWords(word);
      }, this));
    },
    onTextSelect: function(e) {
      var finish, selectedPhrase, start, text;
      text = e.target.value;
      start = e.target.selectionStart;
      finish = e.target.selectionEnd;
      if (selectedPhrase = this.extractPhrase(text, start, finish)) {
        this.props.showRelatedWords(selectedPhrase);
        this.props.textSelection.set(text, start, selectedPhrase);
        this.props.setCurrentState({
          textSelection: this.props.textSelection
        }, {
          inputWord: selectedPhrase
        });
        return this.props.setCurrentState({
          inputWord: selectedPhrase
        });
      }
    },
    onTextChange: function(e) {
      var text;
      text = e.target.value;
      if (this.props.textSelection.clear().setText(text)) {
        return this.props.setCurrentState({
          textSelection: this.props.textSelection
        });
      }
    },
    focus: function() {
      return ReactDOM.findDOMNode(this.refs.input_text).focus();
    },
    closeButton: function() {
      return React.DOM.a({
        href: "/",
        className: this.buttonClass('danger', 'xs'),
        title: 'Make an exit. All current changes will be lost!'
      }, this.icon('remove'));
    },
    helpText: 'Paste in some text to edit. Then select a word!',
    render: function() {
      return React.DOM.form({
        className: 'form-horizontal',
        role: 'form',
        onSubmit: this.onSubmit
      }, React.DOM.div({
        className: 'form-group'
      }, React.DOM.span(null, React.DOM.div({
        className: 'pull-right'
      }, this.closeButton()), React.DOM.label({
        title: 'Paste/copy in some text that needs revising',
        htmlFor: 'input-text'
      }, ' Free Text ')), React.DOM.textarea({
        className: 'form-control input-md',
        ref: 'input_text',
        id: 'input-text',
        rows: 7,
        value: this.props.textSelection.text,
        onSelect: this.onTextSelect,
        onChange: this.onTextChange
      })));
    }
  });
  this.InputWord = React.createClass({
    mixins: [Logger, HtmlHelpers],
    getDefaultProps: function() {
      return {
        inputWord: '',
        labels: '',
        alphaSort: false
      };
    },
    inputWordNode: function() {
      return ReactDOM.findDOMNode(this.refs.input_word);
    },
    focus: function() {
      return this.inputWordNode().focus();
    },
    onWordChange: function(e) {
      var word;
      word = e.target.value;
      return this.props.setCurrentState({
        inputWord: word
      });
    },
    onWordSubmit: function(e) {
      var inputWord;
      e.preventDefault();
      if (inputWord = this.inputWordNode().value) {
        return this.props.showRelatedWords({
          word: inputWord,
          labels: this.labels()
        });
      }
    },
    onSortByClick: function(e) {
      var usageSort;
      usageSort = e.target.checked;
      return this.props.setCurrentState({
        alphaSort: !usageSort
      });
    },
    onLabelsChange: function(e) {
      var label;
      label = e.target.selected;
      return this.props.setCurrentState({
        labels: this.labels()
      });
    },
    onReplaceWordClick: function(e) {
      var inputWord;
      e.preventDefault();
      if (inputWord = this.inputWordNode().value) {
        return this.props.onReplaceWordClick(inputWord);
      }
    },
    clearRelatedWords: function(e) {
      e.preventDefault();
      return this.props.setCurrentState({
        relatedWords: []
      });
    },
    findRelatedXrefWords: function(e) {
      var inputWord;
      e.preventDefault();
      if (inputWord = this.inputWordNode().value) {
        return this.props.showRelatedWords({
          word: inputWord,
          xref: 't',
          labels: this.labels()
        });
      }
    },
    findRelatedPhrases: function(e) {
      var inputWord;
      e.preventDefault();
      if (inputWord = this.inputWordNode().value) {
        return this.props.showRelatedWords({
          word: inputWord,
          phrases: 't'
        });
      }
    },
    labels: function() {
      var labelDom;
      labelDom = ReactDOM.findDOMNode(this.refs.label_selector);
      return labelDom[labelDom.selectedIndex].value;
    },
    hasSelectedText: function() {
      return this.props.flagged('has-selection');
    },
    hasInput: function() {
      return this.props.flagged('has-input-word');
    },
    hasRelated: function() {
      return this.props.flagged('has-related-words');
    },
    controlButtons: function() {
      var canReplace, clearTitle, hasInput, phraseTitle, relatedTitle, replaceTitle, xrefTitle;
      relatedTitle = 'Show some words related to the Lookup word';
      replaceTitle = 'Replace the Lookup word with the selected word in the text';
      xrefTitle = 'Show the cross references of the Lookup word';
      phraseTitle = 'Show the phrases containing the Lookup word';
      clearTitle = 'Clear all of the lists of related words';
      hasInput = this.hasInput();
      canReplace = hasInput && this.hasSelectedText();
      return React.DOM.span({
        className: 'btn-group'
      }, this.htmlClickButton(this.onWordSubmit, 'search', relatedTitle, hasInput, 'primary'), this.htmlClickButton(this.findRelatedXrefWords, 'retweet', xrefTitle, hasInput), this.htmlClickButton(this.findRelatedPhrases, 'list', phraseTitle, hasInput), this.htmlClickButton(this.onReplaceWordClick, 'transfer', replaceTitle, canReplace, 'warning'), this.htmlClickButton(this.clearRelatedWords, 'remove-circle', clearTitle, this.hasRelated(), 'danger'));
    },
    labelSelector: function() {
      return React.DOM.div({
        className: 'form-group'
      }, React.DOM.label({
        title: 'To show only the words related by grammatical category',
        htmlFor: 'label-selector'
      }, "Label  " + this.nbsp), React.DOM.select({
        ref: 'label_selector',
        id: 'label-selector',
        className: 'form-control',
        value: this.props.labels,
        onChange: this.onLabelsChange
      }, React.DOM.option({
        value: ''
      }, ''), React.DOM.option({
        value: 'n'
      }, 'noun'), React.DOM.option({
        value: 'v'
      }, 'verb'), React.DOM.option({
        value: 'adj'
      }, 'adjective'), React.DOM.option({
        value: 'adv'
      }, 'adverb')));
    },
    helpModal: function(modalId) {
      var helpText, title;
      title = HelpText.introTitle;
      helpText = HelpText.introText();
      return this.htmlModal(title, helpText, modalId);
    },
    helpModalLink: function(modalId) {
      var linkClass, title;
      title = 'An introduction and guide';
      linkClass = this.buttonClass('success');
      return this.htmlModalLink(this.icon('info-sign'), linkClass, modalId, title);
    },
    sortBy: function() {
      var title;
      title = 'Show the related word ordered by populatity instead of alphabetically';
      return React.DOM.div({
        className: 'checkbox'
      }, React.DOM.label, null, this.icon('sort'), ' ', React.DOM.input({
        type: 'checkbox',
        value: this.props.alphaSort,
        onClick: this.onSortByClick
      }), React.DOM.small({
        title: title,
        className: 'text-muted'
      }, " Sort by use"));
    },
    render: function() {
      var modalId;
      modalId = 'modal-help';
      return React.DOM.form({
        className: 'form-inline',
        role: 'form',
        onSubmit: this.onWordSubmit
      }, React.DOM.div({
        className: 'form-group'
      }, React.DOM.label({
        title: 'Put in a word to see others strongly related to it',
        htmlFor: 'input-word'
      }, " Lookup " + this.nbsp + " ")), React.DOM.div({
        className: 'form-group'
      }, React.DOM.input({
        type: 'text',
        className: 'form-control',
        ref: 'input_word',
        id: 'input-word',
        value: this.props.inputWord,
        onChange: this.onWordChange
      })), React.DOM.span(null, this.spacedOut(), this.controlButtons(), this.spacedOut(), this.labelSelector(), this.spacedOut(), this.sortBy(), this.spacedOut(), this.helpModalLink(modalId)), React.DOM.span(null, this.helpModal(modalId)));
    }
  });
  initial = '';
  this.ThesaurusPane = React.createClass({
    mixins: [Logger, HtmlHelpers],
    getInitialState: function() {
      return {
        relatedWords: [],
        textSelection: new TextSelection(initial),
        inputWord: '',
        labels: '',
        alphaSort: true
      };
    },
    source: function() {
      var options;
      options = {
        success: this.addRelatedWords
      };
      return this.definitionApi || (this.definitionApi = new DefinitionApi(options));
    },
    dataSource: function() {
      var source;
      source = this.source();
      source.clear();
      source.merge({
        by_usage: !this.state.alphaSort ? true : void 0
      });
      source.merge({
        labels: this.state.labels ? this.state.labels : void 0
      });
      return source;
    },
    nextKey: function(list) {
      if (list.length > 0) {
        return list[0].key + 1;
      } else {
        return 0;
      }
    },
    flagged: function(flag) {
      switch (flag) {
        case 'has-selection':
          return this.state.textSelection.hasSelection();
        case 'has-input-word':
          return this.state.inputWord;
        case 'has-related-words':
          return this.state.relatedWords.length;
        case 'has-input-text':
          return this.state.textSelection.hasText();
        default:
          return;
      }
    },
    addRelatedWords: function(definition) {
      definition['key'] = this.nextKey(this.state.relatedWords);
      this.state.relatedWords.unshift(definition);
      return this.setState({
        relatedWords: this.state.relatedWords
      });
    },
    findRelatedWords: function(data) {
      if (!data) {
        return;
      }
      return this.dataSource().get(data);
    },
    setCurrentState: function(state) {
      this.setState(state);
      return this.forceUpdate();
    },
    replaceWord: function(word) {
      this.state.textSelection.swap(word);
      return this.setState({
        textSelection: this.state.textSelection
      });
    },
    onRelatedWordsClick: function(e) {
      var word;
      word = e.target.innerHTML;
      this.findRelatedWords(word);
      return this.setState({
        inputWord: word
      });
    },
    getChosenOnes: function() {
      var fetched, selected;
      fetched = this.source().fetched;
      selected = this.state.textSelection.history;
      return $.unique((fetched.slice().concat(selected)).sort());
    },
    pullRight: {
      className: 'pull-right'
    },
    heading: function() {
      return React.DOM.h4(this.pullRight, 'Semantic Editor', this.icon('pencil'));
    },
    render: function() {
      return React.DOM.div({
        className: 'thesaurus-pane'
      }, this.htmlRow(this.div(this.nbsp)), this.htmlRow([this.heading, this.div(this.inputWord, 'pull-left')]), this.htmlRow(this.inputText), this.htmlRow(this.wordEdits), this.htmlRow(this.wordList));
    },
    inputWord: function() {
      return React.createElement(InputWord, {
        setCurrentState: this.setCurrentState,
        showRelatedWords: this.findRelatedWords,
        inputWord: this.state.inputWord,
        onReplaceWordClick: this.replaceWord,
        alphaSort: this.state.alphaSort,
        labels: this.state.labels,
        flagged: this.flagged
      });
    },
    inputText: function() {
      return React.createElement(InputText, {
        setCurrentState: this.setCurrentState,
        textSelection: this.state.textSelection,
        showRelatedWords: this.findRelatedWords
      });
    },
    wordEdits: function() {
      return React.createElement(WordEdits, {
        setCurrentState: this.setCurrentState,
        textSelection: this.state.textSelection,
        onRelatedWordsClick: this.onRelatedWordsClick,
        getChosenOnes: this.getChosenOnes,
        flagged: this.flagged
      });
    },
    wordList: function() {
      return React.createElement(WordList, {
        setCurrentState: this.setCurrentState,
        relatedWords: this.state.relatedWords,
        onReplaceWordClick: this.replaceWord,
        showRelatedWords: this.findRelatedWords
      });
    }
  });
  this.WordEdits = React.createClass({
    mixins: [HtmlHelpers, Logger],
    onUndoClick: function(e) {
      e.stopPropagation();
      this.props.textSelection.undo();
      return this.props.setCurrentState({
        textSelection: this.props.textSelection
      });
    },
    setInputWord: function(e) {
      var word;
      e.stopPropagation();
      word = e.target.innerHTML;
      return this.props.setCurrentState({
        inputWord: word
      });
    },
    currentSelection: function(textSelection) {
      return React.DOM.span(null, this.icon('fire'), ' ', React.DOM.strong({
        className: 'text-info',
        ref: 'selection',
        title: 'The currently selected word, ready to be replaced within the text. Click for look up and to show its related words.',
        onClick: this.props.onRelatedWordsClick
      }, textSelection.word), React.DOM.small(null, " (" + (textSelection.position(null, 'verbose')) + ") "));
    },
    lastEdit: function(textSelection) {
      var position, recentChange;
      if (recentChange = textSelection.recentChange()) {
        position = textSelection.position(recentChange[0]);
        return React.DOM.span(null, this.span(' ' + this.nbsp), this.icon('edit'), ' ', React.DOM.span({
          title: 'Click for look up',
          onClick: this.setInputWord
        }, recentChange[1]), React.DOM.small(null, " (" + position + ")"), React.DOM.small(null, React.DOM.cite(null, ' changed to ')), React.DOM.span({
          title: 'Click for look up',
          onClick: this.setInputWord
        }, recentChange[2]));
      } else {
        return this.span;
      }
    },
    lookUpsContent: function(modalId) {
      var colCount, heading, plural, rows, words;
      words = this.props.getChosenOnes();
      plural = words.length === 1 ? '' : 's';
      heading = "" + words.length + " word" + plural + " looked up or selected";
      colCount = Math.min.apply(null, [10, 5 + Math.floor(words.length / 20)]);
      rows = this.take(words, colCount);
      return this.htmlTable(heading, rows);
    },
    lookUpsModal: function(modalId) {
      var title;
      title = 'Chosen Words and Phrases';
      return this.htmlModal(title, this.lookUpsContent(), modalId);
    },
    lookUpsModalLink: function(modalId) {
      var linkClass, title;
      title = 'Show all looked up or selected';
      linkClass = this.buttonClass('default', 'xs');
      return React.DOM.small(null, this.spacedOut(1), this.htmlModalLink(this.icon('expand'), linkClass, modalId, title));
    },
    numEdits: function(textSelection) {
      return React.DOM.small({
        title: textSelection.allChanges(),
        className: 'text-muted'
      }, "" + this.nbsp + " (" + (textSelection.changeCount()) + ")");
    },
    undoLink: function(textSelection) {
      if (textSelection.hasChanges()) {
        return React.DOM.span(null, this.spacedOut(), React.DOM.a({
          href: '#',
          title: 'Undo the the previous change',
          onClick: this.onUndoClick
        }, React.DOM.span(null, this.icon('step-backward'), textSelection.changed(null, 'back to'))));
      } else {
        return this.span;
      }
    },
    edits: function(textSelection) {
      var modalId;
      modalId = 'modal-words';
      return React.DOM.div({
        style: {
          margin: '0 0 10px 0'
        },
        className: 'word-edits'
      }, this.currentSelection(textSelection), this.lastEdit(textSelection), this.lookUpsModalLink(modalId), this.numEdits(textSelection), React.DOM.small(null, this.undoLink(textSelection)), React.DOM.span(null, this.lookUpsModal(modalId)));
    },
    beginner: function() {
      return !(this.props.flagged('has-input-word') || this.props.flagged('has-related-words'));
    },
    helpMessage: function(textSelection) {
      var message;
      if (textSelection.hasText()) {
        message = "No word selected/highlighted.";
        if (this.beginner()) {
          message += " Double click a word in the text to get going!";
        }
      } else {
        message = "Nothing entered in the Free Text area!";
        if (this.beginner()) {
          message += " For example, try pasting in the text from a mail you're about to send.";
        }
      }
      return React.DOM.em({
        className: 'text-warning'
      }, this.icon('warning-sign'), this.spacedOut(), message);
    },
    render: function() {
      var textSelection;
      textSelection = this.props.textSelection;
      if (textSelection.hasSelection()) {
        return this.edits(textSelection);
      } else {
        return this.helpMessage(textSelection);
      }
    }
  });
  this.WordList = React.createClass({
    mixins: [Logger, HtmlHelpers],
    getDefaultProps: function() {
      return {
        relatedWords: []
      };
    },
    removeRelated: function(key) {
      var index, relatedWords;
      index = this.getIndexFor(key);
      relatedWords = this.props.relatedWords.splice(index, 1);
      return this.replaceState({
        relatedWords: relatedWords
      });
    },
    getIndexFor: function(key) {
      var definition, index, _i, _len, _ref;
      index = 0;
      _ref = this.props.relatedWords;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        definition = _ref[_i];
        if (definition.key === key) {
          return index;
        }
        index += 1;
      }
      return null;
    },
    list: function() {
      var definition, props, _i, _len, _ref, _results;
      _ref = this.props.relatedWords;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        definition = _ref[_i];
        props = {
          key: definition.key,
          _key: definition.key,
          definition: definition,
          onReplaceWordClick: this.props.onReplaceWordClick,
          removeRelated: this.removeRelated,
          showRelatedWords: this.props.showRelatedWords,
          setCurrentState: this.props.setCurrentState
        };
        _results.push(React.createElement(WordRelations, props));
      }
      return _results;
    },
    render: function() {
      if (this.props.relatedWords.length) {
        return React.DOM.div({
          className: 'panel panel-default'
        }, React.DOM.div({
          className: 'panel-body'
        }, this.list()));
      } else {
        return this.span();
      }
    }
  });
  this.WordRelations = React.createClass({
    mixins: [HtmlHelpers, Logger],
    onReplaceWordClick: function(e) {
      var clickedWord;
      clickedWord = e.target.innerHTML;
      this.props.onReplaceWordClick(clickedWord);
      return this.props.setCurrentState({
        inputWord: clickedWord
      });
    },
    removeSelf: function(e) {
      var key;
      e.stopPropagation();
      if (key = e.target.parentNode.dataset['key']) {
        return this.props.removeRelated(parseInt(key));
      }
    },
    xremoveSelf: function(e) {
      var hash, key;
      e.stopPropagation();
      if (hash = e.target.parentNode.hash) {
        key = hash.slice(1);
        return this.props.removeRelated(parseInt(key));
      }
    },
    showRelatedWords: function(e) {
      var category, params, target, word, xref;
      e.stopPropagation();
      target = e.target.parentNode.parentNode.dataset;
      word = target['word'];
      category = target['category'];
      xref = target['xref'];
      params = {
        word: word,
        category: category,
        xref: xref
      };
      return this.props.showRelatedWords(params);
    },
    setInputWord: function(e) {
      var target, word;
      e.stopPropagation();
      target = e.target.dataset;
      word = target['word'];
      return this.props.setCurrentState({
        inputWord: word
      });
    },
    separate: function(index) {
      if (index > 0) {
        return ', ';
      } else {
        return '';
      }
    },
    categoryDropDownActivateLink: function() {
      return React.DOM.a({
        className: 'btn btn-info btn-xs',
        href: '#',
        title: 'Show more related words',
        "data-toggle": 'dropdown'
      }, this.icon('list-alt'), ' More ', React.DOM.span({
        className: 'caret'
      }));
    },
    categoryDropDownLink: function(definition, category, count) {
      return React.DOM.a({
        role: 'menuitem',
        tabIndex: '-1',
        href: '#',
        "data-word": definition.name,
        "data-category": category,
        "data-xref": this.xrefed(definition, 't', 'f'),
        onClick: this.showRelatedWords
      }, React.DOM.span(null, React.DOM.span({
        className: 'badge pull-right'
      }, count), TextHelpers.title(category)));
    },
    disableCurrent: function(definition, category) {
      if (category === definition.category_name && !definition._phrases) {
        return 'disabled';
      } else {
        return '';
      }
    },
    countsKey: function(definition) {
      return this.xrefed(definition, 'xref_') + 'word_counts';
    },
    categoryDropDownItems: function(definition) {
      var category, categoryCounts, count, countsKey, key, _results;
      key = 0;
      countsKey = this.countsKey(definition);
      categoryCounts = definition[countsKey];
      _results = [];
      for (category in categoryCounts) {
        count = categoryCounts[category];
        _results.push(React.DOM.li({
          key: (key += 1),
          role: 'presentation',
          className: this.disableCurrent(definition, category)
        }, this.categoryDropDownLink(definition, category, count)));
      }
      return _results;
    },
    categoryDropDownMenu: function(definition) {
      return React.DOM.span({
        className: 'dropdown dropup'
      }, this.categoryDropDownActivateLink(), React.DOM.ul({
        className: 'dropdown-menu',
        role: 'menu'
      }, React.DOM.li({
        className: 'dropdown-header',
        role: 'presentation'
      }, "Other related " + (this.xrefed(definition)) + " words"), this.categoryDropDownItems(definition)));
    },
    displayRelatedWord: function(atts, word, index) {
      return React.DOM.small({
        key: index
      }, React.DOM.span(null, this.separate(index)), React.DOM.span(atts, word.name));
    },
    displayRelatedWords: function(words) {
      if (!(words != null)) {
        return ' ';
      } else if (words.length === 0) {
        return React.DOM.small({
          className: 'text-danger'
        }, "No related words");
      } else {
        return words.map(__bind(function(word, index) {
          var atts;
          atts = {
            key: index,
            className: 'text-info',
            onClick: this.onReplaceWordClick
          };
          return this.displayRelatedWord(atts, word, index);
        }, this));
      }
    },
    displayRelatedWordList: function(key, definition, description, words) {
      var titleSuffix;
      titleSuffix = "Click for look up. Click one of the related words to replace with the selected word.";
      return React.DOM.div({
        className: 'linked-words'
      }, React.DOM.a({
        className: 'btn btn-danger btn-xs',
        title: 'Remove this word list',
        "data-key": key,
        onClick: this.removeSelf
      }, this.icon('remove')), this.span(' '), this.categoryDropDownMenu(definition), this.span(this.nbsp), React.DOM.strong({
        title: "Popularity: " + definition.weight + "%. " + titleSuffix,
        onClick: this.setInputWord,
        "data-word": definition.name
      }, " " + (TextHelpers.title(definition.name)) + " "), React.DOM.small(null, React.DOM.cite(null, " " + description + " " + this.nbsp)), this.displayRelatedWords(words));
    },
    xrefed: function(definition, positive, negative) {
      if (!positive) {
        positive = 'xref';
      }
      if (!negative) {
        negative = '';
      }
      if (definition._xref) {
        return positive;
      } else {
        return negative;
      }
    },
    labels: function(definition) {
      if (definition._labels) {
        return definition._associated_labels.map(function(label) {
          return label + 's';
        }).join(', ');
      } else {
        return definition.label;
      }
    },
    description: function(definition, infix) {
      var xrefed;
      if (xrefed = this.xrefed(definition)) {
        xrefed = "<" + xrefed + ">";
      }
      if (infix == null) {
        infix = definition.category_name;
      }
      return "" + (this.labels(definition)) + " [" + infix + "] " + xrefed;
    },
    relatedKey: function(definition) {
      return this.xrefed(definition, 'xref_') + definition.category_name;
    },
    render: function() {
      var definition, description, key, words;
      definition = this.props.definition;
      if (definition.error) {
        description = definition.error;
        words = null;
      } else if (definition._phrases) {
        description = this.description(definition, 'phrases');
        words = definition['phrases'];
      } else {
        description = this.description(definition);
        key = this.relatedKey(definition);
        words = definition[key];
      }
      return this.displayRelatedWordList(this.props._key, definition, description, words);
    }
  });
}).call(this);
