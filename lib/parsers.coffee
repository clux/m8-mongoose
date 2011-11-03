path        = require 'path'
fs          = require 'fs'
fsx         = require 'fsx'
dir         = __dirname

tempFolder = dir + '/../runtime/'

extGoose = [
  'labels'
  'label'
  'private'
]

extend = (source, dest) ->
  recursive = (source, destination) ->
    for own property of source
      if typeof(destination[property]) is 'object'
        destination[property] = recursive(source[property], destination[property])
      else
        destination[property] = source[property]
    destination
  recursive(source, dest)

clone = (obj) ->
  extend(obj, a={})
  a

sanitizeForMongoose = (obj) ->
  for key,val of obj
    for ex in extGoose
      delete val[ex] if val[ex]?
  obj


# parser used by modul8 in data
exp = ->
  files = (file for file in fsx.readDirSync(tempFolder).files when path.extname(file) is '.json')
  schemas = {}
  for file in files
    name = path.basename(file).split('.')[0] #TODO: better name getting (now one model per file only)
    schemas[name] = fs.readFileSync(file, 'utf8')
  '{'+(name+':'+schema for name,schema of schemas).join(',')+'}'

# this one should be used when the app is using it
exp.register = (name, obj) ->
  cliObj = clone(obj) # obj -> mongoose, cliObj gets serialized

  for key,val of cliObj
    delete cliObj[key] if val.private
    cliObj[key] = [] if val instanceof Array # assume that document[key] exists somewhere else so that brogoose can figure it out

  fs.writeFileSync(tempFolder+name+'.json', JSON.stringify(cliObj))
  sanitizeForMongoose(obj) # mongoose safe version sent back to model

#TODO: domain so that forms code can be easily obtained on this domain

module.exports = exp
