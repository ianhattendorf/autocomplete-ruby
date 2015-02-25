RsenseProvider = require './autocomplete-ruby-provider.coffee'

module.exports =
  config:
    port:
      description: 'The port the rsense server is running on'
      type: 'integer'
      default: 47367
      minimum: 1024
      maximum: 65535

  rsenseProvider: null

  activate: (state) ->
    @rsenseProvider = new RsenseProvider()

  provideAutocompletion: ->
    {providers: [@rsenseProvider]}

  deactivate: ->
    @rsenseProvider?.dispose()
    @rsenseProvider = null
