RsenseProvider = require './autocomplete-ruby-provider.coffee'

module.exports =
  rsenseProvider: null

  activate: (state) ->
    @rsenseProvider = new RsenseProvider()
    return

  provideAutocompletion: ->
    return {providers: [@rsenseProvider]}

  deactivate: ->
    @rsenseProvider?.dispose()
    @rsenseProvider = null
    return
