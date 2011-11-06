path        = require 'path'
fs          = require 'fs'
fsx         = require 'fsx'
dir         = __dirname

tempFolder = dir + '/../runtime/'

toName = (file) ->
  path.basename(file).split('.')[0]

read = (file) ->
  fs.readFileSync(file, 'utf8')

# object injected to modul8's interface when calling
Plugin = (@o={}) ->
  @o.key     or= 'models'
  @o.domain  or= 'mongoose'
  return

Plugin::data = ->
  files = (file for file in fsx.readDirSync(tempFolder).files when path.extname(file) is '.json')
  [@o.key, '{'+('"'+toName(file)+'":'+read(file) for file in files).join(',')+'}']


Plugin::domain = ->
  [@o.domain, dir+'/domain/'] # put forms code on here

# expose Parser class
module.exports = Plugin


if module is require.main
  console.log (new Plugin()).data()
