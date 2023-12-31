# REQUIRES ######################################

bach = require 'bach'
chokidar = require 'chokidar'
fse = require 'fs-extra'
livescript = require 'livescript'
pug = require 'pug'
sass = require 'sass'
terser = require 'terser'

# GLOBAL SINGLETON ##############################

initData = {
  articles: {}
  #articles: {'id-plop': {title: 'it is an article', content: 'an article'}}
  settings: {
    title: 'Korrig'
  }
  tags: []
  #tags: ["a tag"]
}

sgl = {
  cfg: null
  dev: no
  font: [
    'download'
    'list'
    'panelLeftOpen'
    'panelRightOpen'
    'pencil'
    'plus'
    'save'
    'settings'
    'upload'
    'x'
  ]
  gh: no
  korrig: {
    app: ''
    data: JSON.stringify initData
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
    lucide = require 'lucide-static'
    clip = (h, s) ->
      s = s.substring s.search('>') + 2
      s = s.split '\n'
      while s[s.length - 1] is '</svg>' or s[s.length - 1] is '' then s.pop()
      s = s.map (e) -> e.trim()
      "<symbol id=\"#{h}\">" + (s.join '') + '</symbol>'
    lst = sgl.font.map (e) -> clip e, lucide[e]
    sgl.korrig.font = lst.join ''
    cb null, 13
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
  fns =
    if sgl.gh
      [
        # get special store for the gh pages
        #getGHStore
        # link the doc but under 'index.html'
        linkAll
      ]
    else
      [
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
    p = if sgl.gh then 'index' else 'korrig'
    fse.writeFileSync "./builds/#{p}.html", res
    stmp = new Date().toLocaleString()
    console.log "#{stmp} => linking done"
    cb null, 2
  catch e
    cb e, null

testServer = (_) ->
  cwd = process.cwd()
  path = require 'path'
  app = (require 'http').createServer (req, res) ->
    res.writeHead 200, { 'Content-Type': 'text/html', 'dav': 1 }
    if req.method is 'PUT'
      data = ''
      req.on 'data', (chunk) -> data += chunk
      req.on 'end', ->
        savePath = path.resolve cwd, 'builds', 'put-save.html'
        fse.writeFile savePath, data, (err) ->
          if err then throw err
          outKb = (Uint8Array.from Buffer.from(data)).byteLength
          outKb = ((outKb * 0.000977).toFixed 3) + 'kB'
          console.info savePath, outKb
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
  buildDoc = (cb) ->
    sgl.gh = yes
    cb null, 21
  moveToDoc = (cb) ->
    try
      fse.mkdirs './docs'
      fse.moveSync 'builds/*', 'docs/'
      cb null, 20
    catch e
      if e.code is 'EEXIST'
        fse.moveSync 'builds/*', 'docs/'
        cb null, 20
      else cb e, null
  #
  # TODO: build a Korrig version for the gh pages demonstration
  #
  (bach.series buildKorrig, buildDoc, buildKorrig, moveToDoc) finalCb

task 'testing', 'build & run a test server', ->
  (bach.series buildKorrig, testServer) finalCb

task 'try', '', ->
  #
  console.log 'for Cakefile dev purpose'
  #