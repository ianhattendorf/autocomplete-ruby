execSync = require('child_process').execSync

platformHome = process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']

getExecPathFromGemEnv = ->
  stdout = execSync 'gem environment'

  line = stdout.toString().split(/\r?\n/)
           .find((l) -> ~l.indexOf('EXECUTABLE DIRECTORY'))
  if line
    line[line.indexOf(': ') + 2..]
  else
    undefined

module.exports = process.env.GEM_HOME ? getExecPathFromGemEnv() ? "#{platformHome}/.gem/ruby/2.3.0"
