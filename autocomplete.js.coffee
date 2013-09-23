class AutoComplete

  constructor: (options) ->

    @defaults =
      searchField: $('.vm-autocomplete')
      resultsContainer: $('.vm-autocomplete-results')
      minLength: 1
      defaulResultsHtml: '<li><a href="#" data-slug="">All</a></li>'
      keyFocusable: true
      url: ""
      method: "GET"
      delay: 400
      makeSingleResultActive: true
      activeElementValue: ''
      templateSource: '<li><a href="#" data-slug="{{{slug}}}">{{{title}}}</a></li>'
    
    @settings = $.extend( {}, @defaults, options )
    @template = Handlebars.compile(@settings.templateSource)
    @bindEvents()
    @showDefaultResults()

  bindEvents: ->
    @settings.searchField.on 'keyup', @handleSearchFieldKeyUp
    @settings.searchField.on 'keypress', @handleSearchFieldKeyPress
    @settings.resultsContainer.on 'click', 'a', @handleListItemClick

  handleListItemClick: (e) =>
    e.preventDefault()
    $elem = $(e.currentTarget).parents('li')
    @makeItemActive($elem)

  handleSearchFieldKeyPress: (e) =>
    if e.which == 13
      e.preventDefault()

  handleSearchFieldKeyUp: (e) =>
    term = @settings.searchField.val()
    keyCode = e.which
    
    if @settings.keyFocusable
      @arrowKeyFocus(keyCode)
    
    if @isKeySearchable(keyCode) && @isMinLengthMet(term.length)

      clearTimeout( @timer )
      @timer = setTimeout =>
        @fetchResults(term).done (data) =>
          @renderView(data)
      , @settings.delay

    if term.length == 0 && @isKeySearchable(keyCode)
      @showDefaultResults()

  showDefaultResults: =>
    @settings.resultsContainer.html(@settings.defaulResultsHtml)
    activeElement = $('.filters.store').find('li a[data-slug=' + @settings.activeElementValue + ']').parents('li')
    @makeItemActive(activeElement, false)

  arrowKeyFocus: (keyCode) =>

    activeItem = @settings.resultsContainer.find('li.active')
    if keyCode == 40
      if activeItem.length == 0
        $elem = @settings.resultsContainer.find('li:first')
      else
        $elem = activeItem.removeClass('active').next()
    if keyCode == 38
      if activeItem.length == 0
        $elem = @settings.resultsContainer.find('li:last')
      else
        $elem = activeItem.removeClass('active').prev()

    if keyCode == 40 || keyCode == 38
      @makeItemActive($elem)

  makeItemActive: (elem, trigger = true) =>
    @settings.resultsContainer.find('li').removeClass('active')
    elem.addClass('active')
    @settings.activeElementValue = @settings.resultsContainer.find('li.active a').attr('data-slug')
    if trigger
      $.event.trigger
        type: "autocomplete.itemSelected"


  fetchResults: (term) =>
    $.ajax
      url: @settings.url
      type: @settings.method
      dataType: "json"
      data:
        term: term
  
  renderView: (data) =>
    term = @settings.searchField.val()
    if @isMinLengthMet(term.length)

      html = ''
      $.each data, (i, result) =>
        html += @template(result)
      @settings.resultsContainer.html(html)
    
    if @settings.makeSingleResultActive && data.length == 1
      $elem = @settings.resultsContainer.find('li')
      @makeItemActive($elem)

  isKeySearchable: (keyCode) =>
    if keyCode == 40 || keyCode == 38 || keyCode == 13
      false
    else
      true

  isMinLengthMet: (termLength) =>
    if termLength >= @settings.minLength
      true
    else
      false






