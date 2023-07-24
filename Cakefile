# REQUIRES ######################################

bach = require 'bach'
fse = require 'fs-extra'
pug = require 'pug'

# HELPERS #######################################

finalCb = (e, _) ->
  if e? then console.log "ERROR:\n\n#{e}"
  else console.log '\n### TASK COMPLETE ###\n'

compile = (lg, data, cb) ->
  #
  #
  # TODO: compiling fun
  #
  try
    res = switch lg
      when 'ls'
        #
        #
        ''
        #
      when 'pug-rend' then pug.renderFile ""
    #
    #
    cb null, 3
    #
  catch err
    console.error "!!!!!!\n\nCOMPILATION ERROR: #{e}"
    cb err, null

# SUBTASKS ######################################

# TASKS #########################################

task 'build', '', ->
  #
  # TODO: build task
  #
  console.log 'build task ...'
  #
  #
  #

task 'develop', '', ->
  #
  # TODO: use chokidar to compile
  #
  # TODO: develop task
  #
  # TODO: compile some pug
  #
  console.log 'develop task ...'
  #
  #

task 'clean', '', ->
  lst = ['tmp']
  rem = (path, cb) -> fse.remove path, cb
  rems = lst.map((path) -> (cb) -> rem path, cb)
  (bach.series.apply null, rems) finalCb

task 'testing', '', ->
  #
  # TODO: testing task
  #
  console.log 'testing task ...'
  #
