RsenseClient = require './autocomplete-ruby-client.coffee'

module.exports =
class RsenseProvider
  id: 'autocomplete-ruby-rubyprovider'
  selector: '.source.ruby'
  rsenseClient: null

  constructor: ->
    @rsenseClient = new RsenseClient()

  requestHandler: (options) ->
    return new Promise (resolve) =>
      # rsense expects 1-based positions
      row = options.cursor.getBufferRow() + 1
      col = options.cursor.getBufferColumn() + 1
      completions = @rsenseClient.checkCompletion(options.editor,
      options.buffer, row, col, (completions) =>
        suggestions = @findSuggestions(options.prefix, completions)
        return resolve() unless suggestions?.length
        return resolve(suggestions)
      )

  findSuggestions: (prefix, completions) ->
    if completions?
      suggestions = []
      for completion in completions when completion.name isnt prefix
        kind = completion.kind.toLowerCase()
        suggestion =
          word: completion.name
          prefix: prefix
          label: "#{kind} (#{completion.qualified_name})"
        suggestions.push(suggestion)
      return suggestions
    return []

  dispose: ->
