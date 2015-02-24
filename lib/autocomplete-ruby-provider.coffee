module.exports =
class RsenseProvider
  id: 'autocomplete-ruby-rubyprovider'
  selector: '.source.ruby'
  rsenseClient: null

  constructor: ->
    @rsenseClient = null

  requestHandler: (options) ->
    row = options.cursor.getBufferRow()
    col = options.cursor.getBufferColumn()
    suggestions = [
      {
        word: 'aaa',
        prefix: ''
      }
    ]
    return suggestions

  dispose: ->
