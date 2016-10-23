RsenseClient = require './autocomplete-ruby-client.coffee'
IS_WIN32 = process.platform == 'win32'

String.prototype.regExpEscape = () ->
  return @replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

module.exports =
class RsenseProvider
  selector: '.source.ruby'
  disableForSelector: '.source.ruby .comment'

  inclusionPriority: 1

  rsenseClient: null

  constructor: ->
    @rsenseClient = new RsenseClient()
    @rsenseClient.startRsenseUnix() if !IS_WIN32
    @lastSuggestions = []

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    @rsenseClient.startRsenseWin32() if IS_WIN32
    new Promise (resolve) =>
      # rsense expects 1-based positions
      row = bufferPosition.row + 1
      col = bufferPosition.column + 1
      completions = @rsenseClient.checkCompletion(editor,
      editor.buffer, row, col, (completions) =>
        suggestions = @findSuggestions(prefix, completions)
        if(suggestions?.length)
          @lastSuggestions = suggestions

        # request completion on `.` and `::`
        resolve(@lastSuggestions) if prefix == '.' || prefix == '::'

        resolve(@filterSuggestions(prefix, @lastSuggestions))
      )

  findSuggestions: (prefix, completions) ->
    if completions?
      suggestions = []
      for completion in completions
        kind = completion.kind.toLowerCase()
        kind = "import" if kind == "module"
        suggestion =
          text: completion.name
          type: kind
          leftLabel: completion.base_name
        suggestions.push(suggestion)
      suggestions.sort (x, y) ->
        if x.text>y.text
          1
        else if x.text<y.text
          -1
        else
          0

      return suggestions
    return []


  filterSuggestions: (prefix, suggestions) ->
    suggestionBuffer = []

    if(!prefix?.length || !suggestions?.length)
      return []

    expression = new RegExp("^"+prefix.regExpEscape(), "i")

    for suggestion in suggestions
      if expression.test(suggestion.text)
        suggestion.replacementPrefix = prefix
        suggestionBuffer.push(suggestion)

    return suggestionBuffer

  dispose: ->
    return @rsenseClient.stopRsense() if IS_WIN32
    @rsenseClient.stopRsenseUnix()
