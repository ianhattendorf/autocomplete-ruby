RsenseProvider = require './autocomplete-ruby-provider.coffee'
exec = require('child_process').exec

platformHome = process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']

getExecPathFromGemEnv = ->
  exec 'gem environment', (err, stdout, stderr) ->
    unless err
      line = stdout.split(/(\r)?\n/)
               .find((l) -> ~l.indexOf('EXECUTABLE DIRECTORY'))
      if line
        line[line.indexOf(': ')..]
      else
        undefined

GEM_HOME = process.env.GEM_HOME ? getExecPathFromGemEnv() ? "#{platformHome}/.gem/ruby/2.3.0"
  

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

  rsenseProvider: null

  activate: (state) ->
    @rsenseProvider = new RsenseProvider()

  provideAutocompletion: ->
    @rsenseProvider

  deactivate: ->
    @rsenseProvider?.dispose()
    @rsenseProvider = null
