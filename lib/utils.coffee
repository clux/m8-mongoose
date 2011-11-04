
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

module.exports = {clone}
