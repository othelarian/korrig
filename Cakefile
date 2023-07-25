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
      when 'pug'
        if data.top then pug.compileFile 'src/index.pug'
        else
          opts = { compileDebug: false, name: data.name }
          pug.compileFileClient data.path, opts
    #
    #
    cb null, res
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
  compile 'pug', { top: yes }, (e, res) ->
    #
    console.log res
    #
    console.log '###############'
    console.log res()
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
  (bach.series rems) finalCb

task 'testing', '', ->
  #
  # TODO: testing task
  #
  console.log 'testing task ...'
  #
