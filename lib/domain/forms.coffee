# can be used on the server

###PROBLEM: Something needs to maintain a list resource state. I need:
1. (in case of active user) : the set of their respective summaries (need to be passed down in which case UI needs to wait under current rules, or cached)
  Do not want to wait for render -> need to make sure we get these things either immediately (probably good anyway), or when an administrative action is taken
2. (in case of a new user) : the set of popular summaries (need to be passed down as well)

At this point, the FG should only have to get the right weighted union of the two above, and we ned to union in the current saved summaries for this document
Probably good to make a convenience function that can construct this from the 3 list in one go
###
FormGenerator = (modelName, listResourceName) ->
  @model = require('data::mongoose')[modelName]
  console.error("#{modelName} not found in data::mongoose") if !@model
  return

FormGenerator::input = (name, attr, value) ->
  el = new ElementGenerator
    id      : 'id_'+name
    type    : 'text'
    name    : name
    value   : value

  switch mongooseType(attr)
    when 'String'
      if attr.enums
        options = []
        for e in attr.enums
          selectStr = if e.value is value then ' selected' else ''
          options.push "<option value=\"#{e.value}\"#{selectStr}>#{e.name}</option>"

        el.options('select',false).set
          value   : options.join('')
          type    : null
        el.get()
      else if attr.long
        el.options('textarea', false).set
          type        : null  # textarea doesnt have a type attribute
          placeholder : '<%=placeholder%>'
      else
        el.set
          placeholder : '<%=placeholder%>'

      el.get()
    when 'Date'
      #$.fn.eventTime creates the two sub elements
      el.set
        type    : 'hidden'
        class   : 'eventTime'
      el.get()
    when 'Boolean'
      el.set
        type    : 'checkbox'
        class   : 'boxbutton'
        labels  : if attr.labels then attr.labels else null
      el.get()
    when 'Number'
      el.set
        placeholder   : '<%=placeholder%>'
        class         : if attr.max? and attr.min? then 'slider' else null
        data_min      : if attr.min? then attr.min else null
        data_max      : if attr.max? then attr.max else null
      el.get()
    when 'Array'
      o = []
      o.push '<div><ul>'
      #o.push '<li>'+choice+'</li>' for choice in LOCALUSERSLIST[name]
      #@
      o.push '</ul></div>'
      #print out a guided help div
      #it must include an autocompleter, and a checkable array of favourites
      #if we cache localUser, then client can know its friends etc for these things, state management FTW

      #NB2: if we are in edit mode, it does not simply suffice to give the localuserlist[name]
      #we would have to take the unique union of localuserlist[name] and the list we get from the document (what already is there)
      #(whats in the document is the list we passed in as value)
      o.join ''
    else
      'Bad type'

FormGenerator::field = (name, value, label) ->
  attr = @model[name]
  return "#{name} not found in model attrs" if !attr
  return @input(name, attr, value) if !label
  return '<label for="id_#{name}">#{label} #{@input(name,attr,value)}</label>'


# helpers

mongooseType = (attr) ->
  type = if typeof attr is 'object' then attr.type else attr
  if typeof type isnt 'function'
    console.error('bad type:',type)
    return 'undefined'
  typeMap(type)

typeMap = (type) ->
  return 'Array' if type instanceof Array # mongoose just says array with one element in, the document, to indicate an array of embedded docs
  return 'Date' if new type() instanceof Date
  return 'Boolean' if new type() instanceof Boolean
  return 'Number' if new type() instanceof Number
  return 'String' if new type() instanceof String



ElementGenerator =  (@obj, @selfClose=true) ->

# value in 2nd param (if setting one), or value in firstObj can be set to null to unset
ElementGenerator::set = (first, val) ->
  object = if val isnt undefined then {first:val} else first #first can be a key or an object
  (if v is null then delete @obj[k] else @obj[k] = v) for own k,v of object
  @

ElementGenerator::options = (@name, @selfClose=true) -> @

ElementGenerator::get = ->
  value = @obj.value
  if value then delete @obj.value
  o = []
  elName = @name or 'input'
  o.push '<'+elName
  o.push key+'="'+val+'"' for key,val of @obj
  if @selfClose
    o.push 'value="'+value+'"'
    o.push '/>'
  else
    o.push '>'+value+'</'+elName+'>'
  o.join ' '



###
if module is require.main then do -> # tests below, use do -> fn wrapper so we dont shadow DM inside required module
  tap = require 'tap'
  test = tap.test
  tap.plan(2)

  # dependencies
  DM = {internal: {models:{user:{} }}} #WONT WORK ANYMORE



  test "\nTest suggest()", (t) ->
    testObj = {}
    DM.internal.models.user =
      'slide'   : {type:Number, min:0, max:5}
      'selector': {type:String, enums:[{value:0,name:'None'}, {value:1, name:'Some'},{value:2, name:'Third'}]}
      'longText': {type:String, long:true}
      'noslide' : {type:Number, min:5}
      'date1'   : Date
      'lista'   : [testObj]
    fg = new FormGenerator('user')

    slider = fg.field('slide')
    t.equal(slider.indexOf('input '),1, "Number both min,max => input")
    t.equal(slider[-3..], ' />', "Number both min,max => input, self-closing")

    date = fg.field('date1', Date.now)
    t.equal(date.indexOf('input'), 1, "Date => input")
    t.equal(date[-3..], ' />', "Date => input, self-closing")

    select = fg.field('selector', 1)
    t.equal(select.indexOf('select'), 1, "String with enums => select")
    t.equal(select.split('<option').length, DM.internal.models.user.selector.enums.length+1, "String with enums has right number of options")
    t.equal(select[-9...-1], '</select', "String with enums => select, not self-closing")

    area = fg.field('longText','abc')
    t.equal(area.indexOf('textarea'), 1, "string with long:true is textarea")
    t.equal(area[-9...-1], 'textarea', "string with long:true is textarea (and it is not self closing)")

    input = fg.field('noslide',5)
    t.equal(input.indexOf('input '),1, "Number => input")
    t.equal(input[-3..], ' />', "Number => input, self-closing")

    #arry = fg.field('lista', [{name:'cluxinator', icon:'abc.png',short:'clux'}])

    t.end()


  test "\ntypeMap()", (t) ->
    t.equal(typeMap(Date),'Date', "typeMap(Date) is 'Date'")
    t.equal(typeMap(Boolean),'Boolean', "typeMap(Boolean) is 'Boolean'")
    t.equal(typeMap(Number),'Number', "typeMap(Number) is 'Number'")
    t.equal(typeMap(String),'String', "typeMap(String) is 'String'")
    t.equal(typeMap([Date]),'Array', "typeMap(Array) is 'Array'")
    t.end()
###
