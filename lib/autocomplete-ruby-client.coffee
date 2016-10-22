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

  # Check if an rsense server is already running.
  # This can detect all rsense processes even those without pid files.
  startRsenseUnix: =>
    start = @startRsenseCommand

    exec("ps -ef | head -1; ps -ef | grep java",
      (error, stdout, stderr) ->
        if error != null
          atom.notifications.addError('Error looking for resense process',
              {detail: "exec error: #{error}", dismissable: true}
            )
        else
          @rsenseProcess = $.grep(TableParser.parse(stdout), (process) ->
            process.CMD.join(' ').match( /rsense.*--port.*--path/ )
          )[0]
          if @rsenseProcess == undefined || @rsenseProcess == null
            start()
          else
            @rsenseStarted = true
    )

  # Before trying to start in Windows we need to kill any existing rsense servers, so
  # as to not end up with multiple rsense servsers unkillable by 'rsense stop'
  # This means that running two atoms and closing one, kills rsense for the other
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

  # First count how many atom windows are open.
  # If there is only one open, then kill the rsense process.
  # This is also able to kill an rsense process without a pid file.
  # Otherwise do nothing so you will still be able to use rsense in other windows.
  stopRsenseUnix: =>
    stopCommand = @stopRsense

    exec("ps -ef | head -1; ps -ef | grep atom",
      (error, stdout, stderr) ->
        if error != null
          atom.notifications.addError('Error looking for atom process',
              {detail: "exec error: #{error}", dismissable: true}
            )
        else
          @atomProcesses = $.grep(TableParser.parse(stdout), (process) ->
            process.CMD.join(' ').match( /--type=renderer.*--node-integration=true/ )
          )
          if @atomProcesses.length < 2
            process.kill(@rsenseProcess.PID[0], 'SIGKILL') if @rsenseProcess
            stopCommand()
    )

  stopRsense: =>
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
