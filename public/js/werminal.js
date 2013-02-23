// Generated by CoffeeScript 1.4.0
var WermCtrl;

angular.module('werminal', ['ui', 'werm-directives']);

WermCtrl = function($scope, $http, $window, $interpolate, $compile) {
  var completeTree, defaultTemplate;
  defaultTemplate = 'blank.html';
  $scope.wermInput = '';
  $scope.wermOutput = '';
  $scope.template = defaultTemplate;
  $scope.autocompleteMatches = '';
  $scope.lastError = '';
  $scope.runCommand = function($event) {
    var command;
    command = $event.target.value;
    $http.get('/e', {
      params: {
        q: command
      }
    }).success(function(data) {
      $scope.autocompleteMatches = '';
      $scope.wermInput = '';
      if (data.redirect) {
        return $window.location.href = data.redirect;
      } else if (data.popup) {
        return $window.open(data.popup, '_blank');
      } else if (data.stdout) {
        if (data.template) {
          $scope.template = data.template;
        } else {
          $scope.template = defaultTemplate;
        }
        return $scope.wermOutput = data.stdout;
      } else if (data.error) {
        return $scope.lastError = data.error;
      } else {
        return $window.alert('invalid response');
      }
    });
    return $event.preventDefault();
  };
  completeTree = function(tokens, subTree) {
    var leftToken, matches, onlyMatch, partialMatches;
    leftToken = tokens.shift();
    if (!subTree._tokens) {
      return [];
    }
    if (subTree._tokens && subTree._tokens[leftToken]) {
      return _.map(completeTree(tokens, subTree._tokens[leftToken]), function(completion) {
        var out;
        return out = {
          _cmd: leftToken + ' ' + completion._cmd,
          _desc: completion._desc
        };
      });
    }
    partialMatches = _.filter(_.keys(subTree._tokens), function(completionOption) {
      return completionOption.match(new RegExp(leftToken, 'i'));
    });
    if (partialMatches.length === 1) {
      onlyMatch = partialMatches.pop();
      matches = _.map(completeTree([], subTree._tokens[onlyMatch]), function(completion) {
        var out;
        return out = {
          _cmd: onlyMatch + ' ' + completion._cmd,
          _desc: completion._desc
        };
      });
      if (subTree._tokens[onlyMatch]._leaf) {
        matches.unshift({
          _cmd: onlyMatch,
          _desc: subTree._tokens[onlyMatch]._desc
        });
      }
      return matches;
    } else {
      return _.map(partialMatches, function(match) {
        var out;
        return out = {
          _cmd: match,
          _desc: subTree._tokens[match]._desc
        };
      });
    }
  };
  $http.get('/autocomplete').success(function(autocompleteData) {
    return $scope.autocomplete = function(wermInput) {
      var tokens;
      $scope.lastError = '';
      if (!wermInput) {
        return $scope.autocompleteMatches = '';
      } else {
        tokens = wermInput.split(' ');
        return $scope.autocompleteMatches = completeTree(tokens, autocompleteData);
      }
    };
  });
};

angular.module('werm-directives', []).directive('contenteditable', function() {
  return {
    restrict: 'A',
    require: '?ngModel',
    link: function(scope, element, attrs, ngModel) {
      var read;
      if (!ngModel) {
        return;
      }
      ngModel.$render = function() {
        return element.html(ngModel.$viewValue || '');
      };
      element.bind('blur keyup change', function() {
        return scope.$apply(read);
      });
      read = function() {
        return ngModel.$setViewValue(element.html());
      };
      read();
    }
  };
}).directive('wermInput', function($window) {
  return {
    replace: true,
    restrict: 'E',
    template: '<textarea></textarea>',
    scope: false,
    link: function(scope, element, attrs) {
      $('#popupText').on('keydown', function(event) {
        if ((event.keyCode === 13 && event.ctrlKey) || (event.keyCode === 27)) {
          return event.preventDefault();
        }
      });
      $('#popupText').on('keyup', function(event) {
        var rows, value;
        if (event.keyCode === 13 && !event.ctrlKey && !event.shiftKey && !event.altKey) {
          value = $(event.target).val();
          rows = (value.match(/\n/g) || []).length;
          $(event.target).attr('rows', rows + 2);
        }
        if ((event.keyCode === 13 && event.ctrlKey) || (event.keyCode === 27)) {
          event.preventDefault();
          return scope.$apply(function() {
            var closeQuoteOrEndPos, oldInput, openQuotePos, relativeCloseQuotePos;
            openQuotePos = scope.wermInput.substr(0, scope.lastInputPosition).lastIndexOf('"');
            relativeCloseQuotePos = scope.wermInput.substr(scope.lastInputPosition).indexOf('"');
            relativeCloseQuotePos = relativeCloseQuotePos != null ? relativeCloseQuotePos : scope.wermInput.length;
            closeQuoteOrEndPos = scope.lastInputPosition + relativeCloseQuotePos;
            oldInput = scope.wermInput;
            if ($(event.target).val()) {
              scope.wermInput = oldInput.substr(0, openQuotePos + 1) + $(event.target).val() + '" ' + oldInput.substr(closeQuoteOrEndPos + 1);
            } else {
              scope.wermInput = oldInput.substr(0, openQuotePos) + oldInput.substr(closeQuoteOrEndPos + 1);
            }
            return $(event.target).closest('.input-popup').hide(1, function() {
              $window.focusAtEnd(element[0]);
              return $(event.target).val('');
            });
          });
        }
      });
      return $(element).on('keyup click', function(event) {
        var cursorPosition, nQuotesAfterCursor, nQuotesBeforeCursor, rows, value;
        cursorPosition = $window.getTextBoxCaretPosition(event.target);
        value = $(event.target).val();
        nQuotesBeforeCursor = (value.substr(0, cursorPosition).match(/\"/g) || []).length;
        nQuotesAfterCursor = (value.substr(cursorPosition).match(/\"/g) || []).length;
        rows = (value.match(/\n/g) || []).length;
        $(event.target).attr('rows', rows + 2);
        $('#popup').css({
          top: $(element).outerHeight()
        });
        if ($window.isOdd(nQuotesBeforeCursor)) {
          return $(element).parent().find('#popup').show(1, function() {
            var closeQuoteOrEndPos, openQuotePos, quotedString, relativeCloseQuotePos;
            scope.lastInputPosition = cursorPosition;
            $(element).parent().find('#popupText').focus();
            openQuotePos = value.substr(0, cursorPosition).lastIndexOf('"');
            relativeCloseQuotePos = value.substr(cursorPosition).indexOf('"');
            relativeCloseQuotePos = relativeCloseQuotePos != null ? relativeCloseQuotePos : value.length;
            closeQuoteOrEndPos = cursorPosition + relativeCloseQuotePos;
            quotedString = value.substr(openQuotePos + 1, closeQuoteOrEndPos - openQuotePos - 1);
            return $(element).parent().find('#popupText').val(quotedString);
          });
        }
      });
    }
  };
});
