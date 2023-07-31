# REQUIRES ######################################

bach = require 'bach'
chokidar = require 'chokidar'
fse = require 'fs-extra'
livescript = require 'livescript'
lucide = require 'lucide-static'
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
    font: ''
    mirror: ''
    package: null
    style: ''
  }
  src: { # lg: '' , sgl: '', (pug => name: '')
    'src/index.pug': {}
    'src/main.ls': {}
    'src/style.sass': {}
  }
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
    if data.top then sgl.top = pug.compileFile 'src/index.pug'
    else
      r = switch lg
        when 'ls'
          code = await fse.readFile data.path, { encoding: 'utf-8' }
          (await terser.minify(livescript.compile code, {})).code
        when 'pug'
          opts = { compileDebug: no, name: data.name }
          if data.inline? then opts.inlineRuntimeFunctions = data.inline
          (await terser.minify(pug.compileFileClient data.path, opts)).code
        when 'sass' then (sass.compile data.path, { style: 'compressed' }).css
      p = data.sgl.split '.'
      switch p.length
        when 1 then sgl.korrig[p[0]] = r
        when 2 then sgl.korrig[p[0]][p[1]] = r
    cb null, (if data.cbid? then data.cbid else 3)
  catch err
    console.error "!!!!!!\n\nCOMPILATION ERROR: #{err}"
    cb err, null

finalCb = (e, r) ->
  if e?
    console.log "ERROR:\nResults: #{r}\n\n"
    console.log e
  else if not sgl.dev then console.log '\n### TASK COMPLETE ###\n'

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
  getFont = (cb) ->
    try
      #
      ft = fse.readFileSync 'node_modules/lucide-static/font/lucide.woff'
      sgl.korrig.font =
        '@font-face{font-family:\'lucide\';font-weight:normal;' +
        #'src:url(data:application/x-font-woff;' +
        'src:url(data:font/woff;)' +
        "base64,#{ft.toString 'base64'})" +
        'font-style:normal;}'
      #
      # TODO: check the font
      #
      cb null, 11
    catch e
      console.log 'ERROR on getFont'
      cb e, null
  getPackage = (cb) ->
    sgl.korrig.package = fse.readJsonSync './package.json'
    cb null, 11
  showResult = (cb) ->
    size = ((fse.statSync 'builds/korrig.html').size *  0.000977).toFixed(3)
    console.log '--------------------------------------------------'
    console.log 'Korrig file generated, builds/Korrig.html'
    console.log "version: #{sgl.korrig.package.version}, size: #{size}kB"
    console.log '--------------------------------------------------'
    cb null, 99
  fns = [
    # create the builds dir if necessary
    createDirBuild
    # get the configuration
    getCfg
    # get data from the package.json
    getPackage
    # get the lucide font ready
    getFont
    # get the main LiveScript
    compileApp
    # get the main style
    compileStyle
    # get the pug function in JS format for the save capacity
    compileHtml
    #
    # TODO: include here the plugins
    #
    # TODO: for pug plugin part => data.inline = no
    #
    # get the pug core function to link all
    compileTop
    # link everything together
    linkAll
  ]
  # show some data about the build
  if sgl.stats then fns.push showResult
  (bach.series fns) cbp

compileApp = (cb) -> compile 'ls', { path: 'src/main.ls', sgl: 'app', cbid: 24 }, cb
compileStyle = (cb) -> compile 'sass', { path: 'src/style.sass', sgl: 'style' }, cb
compileHtml = (cb) ->
  compile 'pug', { path: 'src/index.pug', sgl: 'mirror', name: 'korrigHtml' }, cb
compileTop = (cb) -> compile 'pug', { top: yes }, cb

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
  console.log 'Test server running at http://localhost:3000\n'

# TASKS #########################################

task 'build', 'build a production ready version of the app', -> buildKorrig finalCb

task 'clean', '', ->
  lst = ['tmp']
  rem = (path, cb) -> fse.remove path, cb
  rems = lst.map((path) -> (cb) -> rem path, cb)
  (bach.series rems) finalCb

task 'develop', '', ->
  sgl.dev = yes
  launchChokidar = (cb) ->
    watcher = chokidar.watch Object.keys(sgl.src), { awaitWriteFinish: true }
    watcher.on 'change', (path) ->
      path = path.replace '\\', '/'
      console.log "recompiling: #{path}"
      toExec = switch path
        when 'src/index.pug' then [ compileHtml, compileTop ]
        when 'src/style.sass' then [ compileStyle ]
        when 'src/main.ls' then [ compileApp ]
        else
          #
          # TODO: plugin handling zone
          #
          opts = { path, sgl: sgl.src[path].sgl }
          #
          console.debug 'moving into plugin section'
          console.debug opts
          #
          [ (cb) -> compile sgl.src[path].lg, opts, cb ]
      toExec.push linkAll
      (bach.series toExec) finalCb
    watcher.on 'error', (e) ->
      console.log 'CHOKIDAR ERROR:\n'
      console.log e
    cb null, 31
  (bach.series buildKorrig, launchChokidar, testServer) finalCb

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

task 'try', '', ->
  #
  console.log 'for Cakefile dev purpose'
  #
  clip = (h, s) ->
    s = substring s.search '>'
    console.debug s
    #
  #
  lst = [
    'arrowBigUpDash'
  ]
  lst = lst.map (e) -> clip e, lucide[e]
  console.debug lst