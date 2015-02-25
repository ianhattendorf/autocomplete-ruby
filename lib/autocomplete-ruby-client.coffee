$ = require('atom').$
String.prototype.replaceAll = (s,r) -> @split(s).join(r)

module.exports =
class RsenseClient
  projectPath: null

  constructor: ->
    @projectPath = atom.project.getPaths()[0]
    console.log "projectPath: #{@projectPath}"

  checkCompletion: (editor, buffer, row, column, callback) ->
    code = buffer.getText().replaceAll '\n', '\n'
    request =
      command: 'code_completion'
      project: @projectPath
      file: editor.getPath()
      code: code
      location:
        row: row
        column: column
    $.ajax 'http://localhost:47367',
      type: 'POST'
      dataType: 'json'
      data: JSON.stringify request
      error: (jqXHR, textStatus, errorThrown) ->
        console.error textStatus
      success: (data, textStatus, jqXHR) ->
        callback data.completions
    return []
