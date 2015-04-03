RsenseClient = require './autocomplete-ruby-client.coffee'

String.prototype.regExpEscape = () ->
  return @replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

module.exports =
class RsenseProvider
  id: 'autocomplete-ruby-rubyprovider'
  selector: '.source.ruby'
  rsenseClient: null

  constructor: ->
    @rsenseClient = new RsenseClient()
    @lastSuggestions = []

  requestHandler: (options) ->
    return new Promise (resolve) =>
      # rsense expects 1-based positions
      row = options.cursor.getBufferRow() + 1
      col = options.cursor.getBufferColumn() + 1
      completions = @rsenseClient.checkCompletion(options.editor,
      options.buffer, row, col, (completions) =>
        suggestions = @findSuggestions(options.prefix, completions)
        if(suggestions?.length)
          @lastSuggestions = suggestions

        # request completion on `.` and `::`
        return resolve(@lastSuggestions) if options.prefix == '.' || options.prefix == '::'

        return resolve(@filterSuggestions(options.prefix, @lastSuggestions))
      )

  findSuggestions: (prefix, completions) ->
    if completions?
      suggestions = []
      for completion in completions
        kind = completion.kind.toLowerCase()
        suggestion =
          word: completion.name
          prefix: prefix
          label: "#{kind} (#{completion.qualified_name})"
        suggestions.push(suggestion)

      return suggestions
    return []


  filterSuggestions: (prefix, suggestions) ->
    suggestionBuffer = []

    if(!prefix?.length || !suggestions?.length)
      return []

    expression = new RegExp("^"+prefix.regExpEscape(), "i")

    for suggestion in suggestions
      if expression.test(suggestion.word)
        suggestion.prefix = prefix
        suggestionBuffer.push(suggestion)

    return suggestionBuffer

  dispose: ->
