$ = require('jquery')
String.prototype.replaceAll = (s,r) -> @split(s).join(r)

module.exports =
class RsenseClient
  projectPath: null
  serverUrl: null

  constructor: ->
    @projectPath = atom.project.getPaths()[0]
    port = atom.config.get('autocomplete-ruby.port')
    @serverUrl = "http://localhost:#{port}"

  checkCompletion: (editor, buffer, row, column, callback) ->
    code = buffer.getText().replaceAll('\n', '\n').
                            replaceAll('%', '%25')

    request =
      command: 'code_completion'
      project: @projectPath
      file: editor.getPath()
      code: code
      location:
        row: row
        column: column

    $.ajax @serverUrl,
      type: 'POST'
      dataType: 'json'
      data: JSON.stringify request
      error: (jqXHR, textStatus, errorThrown) ->
        # send empty array to callback
        # to avoid autocomplete-plus brick
        callback []
        console.error textStatus
      success: (data, textStatus, jqXHR) ->
        callback data.completions

    return []
