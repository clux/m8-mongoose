$ = require('jQuery') # i.e. if required in a jQuery less environment || jQuery not arbitered, modul8 will throw

# Will observe all input elements and certain common form helpers that are found inside el
exports.formObserve = (el) ->
  inputs = $('input', el)
  selects = $('select', el) #each apply selectmenu
  checkboxes = $('input.boxbutton', inputs)
  dates = inputs.filter('.eventTime')
  checkboxes.map (box) ->
    b = $(box)
    labels = b.attr('labels')
    b.boxbutton(labels) if labels

  dates.map (date) ->
    $(date).eventTime()

  selects.map (select) ->
    $(select).selectmenu()
