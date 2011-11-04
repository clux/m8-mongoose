fs          = require 'fs'
utils       = require './utils'

# register method used by app
# this must be snuck in before registering an object with mongoose
module.exports = (name, obj) ->
  cliObj = utils.clone(obj) # obj -> mongoose, cliObj gets serialized

  for key,val of cliObj
    delete cliObj[key] if val.private # dont export private properties to the client
    cliObj[key] = [] if val instanceof Array # assume that document[key] exists somewhere else so that client code can figure it out

  fs.writeFileSync(tempFolder+name+'.json', JSON.stringify(cliObj))
  sanitizeForMongoose(obj) # mongoose safe version sent back to model

sanitizeForMongoose = (obj) ->
  for key,val of obj
    delete val[ex] if val[ex]? for ex in extGoose # dont include new properties as they are not for mongoose
  obj
