# REQUIRES ######################################

bach = require 'bach'
#coffeePlugin = require 'esbuild-coffeescript'
#esbuild = require 'esbuild'
fse = require 'fs-extra'
livescript = require 'livescript'
pug = require 'pug'
sass = require 'sass'

# GLOBAL SINGLETON ##############################

sgl = {
  cfg: null
  korrig: {
    script: ''
    style: ''
  }
  package: null
  tmp: {
    css: ''
    html: ''
    js: ''
    top: null
  }
}

# HELPERS #######################################

compile = (lg, data, cb) ->
  try
    switch lg
      when 'ls'
        code = await fse.readFile data.path, { encoding: 'utf-8' }
        sgl.tmp.js = livescript.compile code, {}
      when 'pug'
        if data.top then sgl.tmp.top = pug.compileFile 'src/index.pug'
        else
          opts = { compileDebug: false, name: data.name }
          sgl.tmp.html = pug.compileFileClient data.path, opts
      when 'sass' then sgl.tmp.css = (sass.compile data.path, { style: 'compressed' }).css
    cb null, (if data.cbid? then data.cbid else 3)
  catch err
    console.error "!!!!!!\n\nCOMPILATION ERROR: #{e}"
    cb err, null

finalCb = (e, _) ->
  if e? then console.log "ERROR:\n\n#{e}"
  else console.log '\n### TASK COMPLETE ###\n'

getCfg = (cb) ->
  cfg = require('./config.default').cfg
  try
    fse.accessSync './config.coffee'
    cfgov = require('./config.coffee').cfg
    cfg[key] = value for key, value of cfgov
  sgl.cfg = cfg
  cb null, 10

# SUBTASKS ######################################

buildKorrig = (cbp) ->
  getPackage = (cb) ->
    sgl.package = fse.readJsonSync './package.json'
    cb null, 0
  linkAll = (cb) ->
    try
      res = sgl.korrig.top sgl
      #
      # TODO: save into a file
      #
      cb null, 2
    catch e
      cb e, null
  moveData = (cb) ->
    sgl.korrig.script = sgl.tmp.js
    sgl.korrig.style = sgl.tmp.css
    cb null, 1
  showResult = (cb) ->
    #
    # TODO: show the version, the final size, and the build path
    #
    #
    cb null, 99
  fns = [
    # get the configuration
    (cb) -> getCfg cb
    # get data from the package.json
    (cb) -> getPackage cb
    # get the main LiveScript
    (cb) -> compile 'ls', { path: 'src/main.ls' }, cb
    # get the main style
    (cb) -> compile 'sass', { path: 'src/style.sass' }, cb
    # move the script and the css into the korrig for the future link
    (cb) -> moveData cb
    # get the pug function in JS format for the save capacity
    (cb) -> compile 'pug', { path: 'src/index.pug' }, cb
    #
    # TODO: how to include the pug script for the save?
    #
    # get the pug core function to link all
    (cb) -> compile 'pug', { top: yes }, cb
    # link everything together
    (cb) -> linkAll cb
    # show some data about the build
    (cb) -> showResult cb
  ]
  (bach.series fns) cbp

# TASKS #########################################

task 'build', 'build a production ready version of the app', -> buildKorrig finalCb

task 'clean', '', ->
  lst = ['tmp']
  rem = (path, cb) -> fse.remove path, cb
  rems = lst.map((path) -> (cb) -> rem path, cb)
  (bach.series rems) finalCb

task 'develop', 'build the app, launch a dev server, and watch to recompile the source', ->
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

task 'ghpages', '', ->
  moveToDoc = (cb) ->
    fse.moveSync 'build/korrig.html', 'docs/korrig.html'
    cb null, 20
  #
  # TODO: build a Korrig version without any plugin
  #
  # TODO: build a Korrig version for the gh pages demonstration
  #
  (bach.series buildKorrig, moveToDoc) finalCb

task 'testing', 'build & run a test server', ->
  #
  # TODO: testing task
  #
  console.log 'testing task ...'
  #
  testServer = (_) ->
    #
    # TODO: running the test server
    #
    console.log 'test server not ready'
    #
  (bach.series buildKorrig, testServer) finalCb
