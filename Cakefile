# REQUIRES ######################################

bach = require 'bach'
chokidar = require 'chokidar'
fse = require 'fs-extra'
livescript = require 'livescript'
pug = require 'pug'
sass = require 'sass'
terser = require 'terser'

# GLOBAL SINGLETON ##############################

sgl = {
  cfg: null
  dev: no
  korrig: {
    app: ''
    data: '{}'
    mirror: ''
    package: null
    style: ''
  }
  src: {}
  stats: yes
  tmp: {
    css: ''
    html: ''
    js: ''
  }
  top: null
}

# HELPERS #######################################

compile = (lg, data, cb) ->
  try
    switch lg
      when 'ls'
        code = await fse.readFile data.path, { encoding: 'utf-8' }
        sgl.tmp.js = (await terser.minify(livescript.compile code, {})).code
      when 'pug'
        if data.top then sgl.top = pug.compileFile 'src/index.pug'
        else
          opts = { compileDebug: no, name: data.name }
          if data.inline? then opts.inlineRuntimeFunctions = data.inline
          sgl.tmp.html = (await terser.minify(pug.compileFileClient data.path, opts)).code
      when 'sass' then sgl.tmp.css = (sass.compile data.path, { style: 'compressed' }).css
    cb null, (if data.cbid? then data.cbid else 3)
  catch err
    console.error "!!!!!!\n\nCOMPILATION ERROR: #{err}"
    cb err, null

finalCb = (e, r) ->
  if e?
    console.log "ERROR:\nResults: #{r}\n\n"
    console.log e
  else console.log '\n### TASK COMPLETE ###\n'

# SUBTASKS ######################################

buildKorrig = (cbp) ->
  createDirBuild = (cb) ->
    try
      fse.mkdirs './builds'
      cb null, 98
    catch e
      if e.code is 'EEXIST' then cb null, 97
      else cb e, null
  getCfg = (cb) ->
    cfg = require('./config.default').cfg
    try
      fse.accessSync './config.coffee'
      cfgov = require('./config.coffee').cfg
      cfg[key] = value for key, value of cfgov
    sgl.cfg = cfg
    cb null, 10
  getPackage = (cb) ->
    sgl.korrig.package = fse.readJsonSync './package.json'
    cb null, 11
  moveData = (cb) ->
    sgl.korrig.app = sgl.tmp.js
    sgl.korrig.style = sgl.tmp.css
    sgl.korrig.mirror = sgl.tmp.html
    cb null, 1
  showResult = (cb) ->
    size = ((fse.statSync 'builds/korrig.html').size *  0.000977).toFixed(3)
    console.log '--------------------------------------------------'
    console.log 'Korrig file generated, builds/Korrig.html'
    console.log "version: #{sgl.korrig.package.version}, size: #{size}kB"
    console.log '--------------------------------------------------'
    cb null, 99
  fns = [
    # create the builds dir if necessary
    (cb) -> createDirBuild cb
    # get the configuration
    (cb) -> getCfg cb
    # get data from the package.json
    (cb) -> getPackage cb
    # get the main LiveScript
    (cb) -> compile 'ls', { path: 'src/main.ls', cbid: 24 }, cb
    # get the main style
    (cb) -> compile 'sass', { path: 'src/style.sass' }, cb
    # get the pug function in JS format for the save capacity
    (cb) -> compile 'pug', { path: 'src/index.pug', name: 'korrigHtml' }, cb
    # move the scripts and the css into the korrig for the future link
    (cb) -> moveData cb
    #
    # TODO: include here the plugins
    #
    # TODO: for pug plugin part => data.inline = no
    #
    # get the pug core function to link all
    (cb) -> compile 'pug', { top: yes }, cb
    # link everything together
    (cb) -> linkAll cb
  ]
  # show some data about the build
  if sgl.stats then fns.push((cb) -> showResult cb)
  (bach.series fns) cbp

linkAll = (cb) ->
  try
    res = sgl.top sgl.korrig
    fse.writeFileSync './builds/korrig.html', res
    cb null, 2
  catch e
    cb e, null

testServer = (_) ->
  cwd = process.cwd()
  path = require 'path'
  app = (require 'http').createServer (req, res) ->
    res.writeHead 200, { 'Content-Type': 'text/html', 'dav': 1 }
    if req.method is 'PUT'
      #
      # TODO: validate the good work of the testing server
      #
      data = ''
      req.on 'data', chunk -> data += chunk
      #
      req.on 'end', ->
        savePath = path.resolve cwd, 'builds', 'put-save.html'
        fse.writeFile savePath, data, (err) ->
          if err then throw err
          outKb = (UInt8Array.from Buffer.from(data)).byteLength
          outKb = ((outKb * 0.000977).toFixed 3) + 'kB'
          console.info savePath, outKb
      #
    url = req.url?.substring 1
    if url? and url.match(/\.\w+$/) and fse.existsSync(path.resolve cwd, url)
      res.end fse.readFileSync(path.resolve cwd, url)
    else res.end fse.readFileSync('builds/korrig.html')
  app.listen 3000, 'localhost'
  console.log 'Test server running at http://localhost:3000'

# TASKS #########################################

task 'build', 'build a production ready version of the app', -> buildKorrig finalCb

task 'clean', '', ->
  lst = ['tmp']
  rem = (path, cb) -> fse.remove path, cb
  rems = lst.map((path) -> (cb) -> rem path, cb)
  (bach.series rems) finalCb

task 'develop', '', ->
  sgl.dev = yes
  #
  # TODO: use chokidar to compile
  #
  # TODO: develop task
  #
  # TODO: compile some pug
  #
  launchChokidar = (cb) ->
    #
    # TODO: put everything needed into chokidar
    #
    sgl.src['src/index.pug'] = { lg: 'pug' }
    sgl.src['src/style.sass'] = { lg: 'sass' }
    sg.src['src/main.ls'] = { lg: 'ls' }
    #
    chokidar.watch Object.keys(sgl.src), { awaitWriteFinish: true }
    chokidar.on 'change', (path) ->
      #
      #
      toExec =
        if path is 'src/index.pug'
          #
          #
        else
          #
          # TODO: handle the plugin case
          #
          moveWatchData = (cb) ->
            #
            #
          #
          [
            (cb) -> compile sgl.src[path].lg, { path }, cb
            (cb) -> moveWatchData cb
          ]
        #
      #
      toExec.push((cb) -> linkAll cb
      (bach.series toExec) finalCb
    #
    chokidar.on 'error', (e) ->
      console.log 'CHOKIDAR ERROR:\n'
      console.log e
    #
  #
  (bach.series buildKorrig, launchChokidar, testServer) finalCb
  #

task 'ghpages', '', ->
  sgl.stats = no
  moveToDoc = (cb) ->
    fse.moveSync 'builds/korrig.html', 'docs/korrig.html'
    cb null, 20
  #
  # TODO: build a Korrig version without any plugin
  #
  # TODO: build a Korrig version for the gh pages demonstration
  #
  (bach.series buildKorrig, moveToDoc) finalCb

task 'testing', 'build & run a test server', ->
  (bach.series buildKorrig, testServer) finalCb
