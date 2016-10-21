$ = require('jquery')
TableParser = require('table-parser')
exec = require('child_process').exec
String.prototype.replaceAll = (s, r) -> @split(s).join(r)

module.exports =
class RsenseClient
  constructor: ->
    @projectPath = atom.project.getPaths()[0]
    @projectPath = '.' unless @projectPath
    @rsensePath = atom.config.get('autocomplete-ruby.rsensePath')
    @port = atom.config.get('autocomplete-ruby.port')
    @serverUrl = "http://localhost:#{@port}"
    @rsenseStarted = false
    @rsenseProcess = null

  startRsenseUnix: =>
    start = @startRsenseCommand
    port = @port
    projectPath = @projectPath

    # This only works for Unix systems
    exec("ps -ef | head -1; ps -ef | grep java.*rsense.*",
      (error, stdout, stderr) ->
        if error != null
          atom.notifications.addError('Error starting rsense',
              {detail: "exec error: #{error}", dismissable: true}
            )
        else
          @rsenseProcess = $.grep(TableParser.parse(stdout), (process) ->
            process.CMD.join(' ').indexOf("--port #{port} --path #{projectPath}") > -1
          )[0]
          if @rsenseProcess == undefined || @rsenseProcess == null
            start()
          else
            @rsenseStarted = true
    )

  startRsenseWin32: =>
    return if @rsenseStarted
    start = @startRsenseCommand

    exec("#{@rsensePath} stop",
      (error, stdout, stderr) =>
        if error == null
          start()
        else
          atom.notifications.addError('Error stopping rsense',
              {detail: "exec error: #{error}", dismissable: true}
            )
          @rsenseStarted = false
    )

  startRsenseCommand: =>
    return if @rsenseStarted
    exec("#{@rsensePath} start --port #{@port} --path #{@projectPath}",
      (error, stdout, stderr) ->
        if error != null
          atom.notifications.addError('Error starting rsense',
              {detail: "exec error: #{error}", dismissable: true}
            )
        else
          @rsenseStarted = true
    )

  stopRsense: =>
    if @rsenseProcess
      process.kill(@rsenseProcess.PID[0], 'SIGKILL');
    return if !@rsenseStarted
    exec("#{@rsensePath} stop",
      (error, stdout, stderr) ->
        if error != null
          atom.notifications.addError('Error stopping rsense',
              {detail: "exec error: #{error}", dismissable: true}
            )
        else
          @rsenseStarted = false
    )

  checkCompletion: (editor, buffer, row, column, callback) =>
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
