RsenseProvider = require './autocomplete-ruby-provider.coffee'

module.exports =
  config:
    rsensePath:
      description: 'The location of the rsense executable'
      type: 'string'
      default: '~/.gem/ruby/2.3.0/bin/rsense'
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
    @rsenseProvider

  deactivate: ->
    @rsenseProvider?.dispose()
    @rsenseProvider = null
