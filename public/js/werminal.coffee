angular.module 'werminal', ['ui', 'werm-directives']

WermCtrl = ($scope, $http, $window, $interpolate, $compile) ->
  defaultTemplate = 'blank.html'
  $scope.wermInput = ''
  $scope.wermOutput = ''
  $scope.template = defaultTemplate
  $scope.autocompleteMatches = ''
  $scope.lastError = ''
  $scope.runCommand = ($event) ->
    command = $event.target.value
    $http.get '/e',
      params:
        q: command
    .success (data) ->
      $scope.autocompleteMatches = ''
      $scope.wermInput = ''
      if data.redirect
        $window.location.href = data.redirect
      else if data.popup
        $window.open data.popup, '_blank'
      else if data.stdout
        if data.template
          $scope.template = data.template
        else
          $scope.template = defaultTemplate
        $scope.wermOutput = data.stdout
      else if data.error
        $scope.lastError = data.error
      else
        $window.alert 'invalid response'

    $event.preventDefault()

  completeTree = (tokens, subTree) ->
    leftToken = tokens.shift()
    if not subTree._tokens
      return []
  
    if subTree._tokens and subTree._tokens[leftToken]
      return _.map completeTree(tokens, subTree._tokens[leftToken]), (completion) ->
        out =
          _cmd: leftToken + ' ' + completion._cmd
          _desc: completion._desc 

    #partial match
    partialMatches = _.filter _.keys(subTree._tokens), (completionOption) ->
      return completionOption.match new RegExp(leftToken, 'i')

    #if theres only one partial match, show the next level of the tree
    if partialMatches.length == 1
      onlyMatch = partialMatches.pop()
      matches = _.map completeTree([], subTree._tokens[onlyMatch]), (completion) ->
        out =
          _cmd: onlyMatch + ' ' + completion._cmd
          _desc: completion._desc
      if subTree._tokens[onlyMatch]._leaf
        matches.unshift
          _cmd: onlyMatch
          _desc: subTree._tokens[onlyMatch]._desc

      return matches
    else
      return _.map partialMatches, (match) ->
        out =
          _cmd: match
          _desc: subTree._tokens[match]._desc


  $http.get('/autocomplete')
  .success (autocompleteData) ->
    $scope.autocomplete = (wermInput) ->
      $scope.lastError = ''
      if not wermInput
        $scope.autocompleteMatches = ''
      else
        tokens = wermInput.split ' '
        $scope.autocompleteMatches = completeTree(tokens, autocompleteData)
        
  return

angular.module('werm-directives', [])
  .directive('contenteditable', () ->
    restrict: 'A' # only activate on element attribute
    require: '?ngModel' #get a hold of NgModelController
    link: (scope, element, attrs, ngModel) ->
      if not ngModel
        return # do nothing if no ng-model

      #Specify how UI should be updated
      ngModel.$render = () ->
        element.html(ngModel.$viewValue || '')

      #Listen for change events to enable binding
      element.bind 'blur keyup change', () ->
        scope.$apply(read)

      #Write data to the model
      read = () ->
        ngModel.$setViewValue(element.html());

      read() # initialize

      return;
  )
  .directive('wermInput', ($window) ->
    replace: true
    restrict: 'E'
    template: '<textarea></textarea>'
    scope: false
    link: (scope, element, attrs) ->
      $('#popupText').on 'keydown', (event) -> # don't register a newline for command keys
        if ( event.keyCode is 13 and event.ctrlKey ) or ( event.keyCode is 27 )
          event.preventDefault()
    
      $('#popupText').on 'keyup', (event) ->
        if event.keyCode == 13 and not event.ctrlKey and not event.shiftKey and not event.altKey
          value = $(event.target).val()
          rows = (value.match(/\n/g) or []).length
          $(event.target).attr 'rows', rows+2

        if ( event.keyCode is 13 and event.ctrlKey ) or ( event.keyCode is 27 )
          event.preventDefault()
          scope.$apply () ->
            #leftOfCursor = scope.wermInput.substr 0, scope.lastInputPosition
            openQuotePos = scope.wermInput.substr(0, scope.lastInputPosition).lastIndexOf('"')

            relativeCloseQuotePos = scope.wermInput.substr(scope.lastInputPosition).indexOf('"')
            relativeCloseQuotePos = if relativeCloseQuotePos? then relativeCloseQuotePos else scope.wermInput.length

            closeQuoteOrEndPos = scope.lastInputPosition + relativeCloseQuotePos
            oldInput = scope.wermInput

            if $(event.target).val()
              scope.wermInput = oldInput.substr(0, openQuotePos + 1) + $(event.target).val() + '" ' + oldInput.substr(closeQuoteOrEndPos + 1)
            else
              # if there is nothing in the popup, get rid of the quotes
              scope.wermInput = oldInput.substr(0, openQuotePos) + oldInput.substr(closeQuoteOrEndPos + 1)
  
            $(event.target).closest('.input-popup').hide 1, () ->
              $window.focusAtEnd(element[0]) #element is an array for some reason, need the first index
              $(event.target).val('')
      
      $(element).on 'keyup click' , (event) ->
        cursorPosition = $window.getTextBoxCaretPosition(event.target)
        value = $(event.target).val()
        nQuotesBeforeCursor = (value.substr(0, cursorPosition).match(/\"/g) or []).length
        nQuotesAfterCursor = (value.substr(cursorPosition).match(/\"/g) or []).length
  
        rows = (value.match(/\n/g) or []).length
        $(event.target).attr 'rows', rows+2

        $('#popup').css
          top: $(element).outerHeight()
          
        if $window.isOdd(nQuotesBeforeCursor)
          $(element).parent().find('#popup').show 1, () -> #needs to be length 1 so that its visible when we run callback
            #if nQuotesAfterCursor is 0
            scope.lastInputPosition = cursorPosition
            $(element).parent().find('#popupText').focus()
            openQuotePos = value.substr(0, cursorPosition).lastIndexOf('"')
            relativeCloseQuotePos = value.substr(cursorPosition).indexOf('"')
            relativeCloseQuotePos = if relativeCloseQuotePos? then relativeCloseQuotePos else value.length
            closeQuoteOrEndPos = cursorPosition + relativeCloseQuotePos
   
            quotedString = value.substr(openQuotePos + 1, closeQuoteOrEndPos - openQuotePos - 1)
            $(element).parent().find('#popupText').val(quotedString)
              
  )
          
          
      