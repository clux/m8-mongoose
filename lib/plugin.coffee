path        = require 'path'
fs          = require 'fs'
fsx         = require 'fsx'
dir         = __dirname
#forms       = require './domain/forms'

tempFolder = dir + '/../runtime/'

toName = (file) ->
  path.basename(file).split('.')[0]

read = (file) ->
  fs.readFileSync(file, 'utf8')

class Plugin
  constructor : (@name='mongoose') ->

  data : ->
    files = (file for file in fsx.readDirSync(tempFolder).files when path.extname(file) is '.json')
    '{'+('"'+toName(file)+'":'+read(file) for file in files).join(',')+'}' # strings by default are assumed to be pre-serialized from plugins

  domain : ->
    dir+'/domain/' # put forms code on here

# expose Parser class
module.exports = Plugin


if module is require.main
  console.log (new Plugin()).data()
