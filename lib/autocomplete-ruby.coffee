RsenseProvider = require './autocomplete-ruby-provider.coffee'

module.exports =
  rsenseProvider: null

  activate: (state) ->
    @rsenseProvider = new RsenseProvider()

  provideAutocompletion: ->
    {providers: [@rsenseProvider]}

  deactivate: ->
    @rsenseProvider?.dispose()
    @rsenseProvider = null
