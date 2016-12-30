RsenseProvider = require './autocomplete-ruby-provider.coffee'

GEM_HOME = process.env.GEM_HOME ? '~/.gem/ruby/2.3.0'

module.exports =
  config:
    rsensePath:
      description: 'The location of the rsense executable'
      type: 'string'
      default: "#{GEM_HOME}/bin/rsense"
    port:
      description: 'The port the rsense server is running on'
      type: 'integer'
      default: 47367
      minimum: 1024
      maximum: 65535
    suggestionPriority:
      description: 'Show autocomplete-ruby content before default autocomplete-plus provider'
      default: false
      type: 'boolean'

  rsenseProvider: null

  activate: (state) ->
    @rsenseProvider = new RsenseProvider()

  provideAutocompletion: ->
    @rsenseProvider

  deactivate: ->
    @rsenseProvider?.dispose()
    @rsenseProvider = null
