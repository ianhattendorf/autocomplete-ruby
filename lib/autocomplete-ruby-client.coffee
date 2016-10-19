$ = require('jquery')
exec = require('child_process').exec
String.prototype.replaceAll = (s, r) -> @split(s).join(r)

module.exports =
class RsenseClient
  projectPath: null
  rsensePath: null
  serverUrl: null
  rsenseStarted: null

  constructor: ->
    @projectPath = atom.project.getPaths()[0]
    @projectPath = '.' unless @projectPath
    @rsensePath = atom.config.get('autocomplete-ruby.rsensePath')
    port = atom.config.get('autocomplete-ruby.port')
    @serverUrl = "http://localhost:#{port}"
    @rsenseStarted = false

  startRsense: ->
    # Before trying to start we need to kill any existing rsense servers, so
    # as to not end up with multiple rsense servsers unkillable by 'rsense stop'
    # This means that running two atoms and closing one, kills rsense for the other
    return if @rsenseStarted == true
    @rsenseStarted = true

    exec("#{@rsensePath} stop",
      (error, stdout, stderr) =>
        if error == null

          port = atom.config.get('autocomplete-ruby.port')
          exec("#{@rsensePath} start --port #{port} --path #{@projectPath}",
            (error, stdout, stderr) ->
              if error != null
                atom.notifications.addError('Error starting rsense',
                    {detail: "exec error: #{error}", dismissable: true}
                  )
                @rsenseStarted = false
          )

        else
          atom.notifications.addError('Error stopping rsense',
              {detail: "exec error: #{error}", dismissable: true}
            )
          @rsenseStarted = false
    )

  stopRsense: ->
    exec("#{@rsensePath} stop",
      (error, stdout, stderr) ->
        if error != null
          atom.notifications.addError('Error stopping rsense',
              {detail: "exec error: #{error}", dismissable: true}
            )
        @rsenseStarted = false
    )

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
      contentType: 'application/json',
      data: JSON.stringify request
      error: (jqXHR, textStatus, errorThrown) ->
        # send empty array to callback
        # to avoid autocomplete-plus brick
        callback []
        console.error textStatus
      success: (data, textStatus, jqXHR) ->
        callback data.completions

    return []
