# UTILS ######################################

function c-elt tag, attrs = {}, txt = void, html = void
  elt = document.createElement tag
  for k, v of attrs then elt.setAttribute k, v
  if txt? then elt.innerText = txt
  else if html? then elt.innerHTML = html
  elt

function q-sel s, a = no
  if a then document.querySelectorAll s
  else document.querySelector s

function tog s, t, a = no
  r = q-sel s, a
  if not a then r = [r]
  for e in r then if t then e.removeAttribute \hidden else e.setAttribute \hidden ''

# STORE ######################################

KorrigState =
  # functional part
  create-id: -1
  inits: []
  narrowed: no
  notif-id: -1
  panel: \l
  server-op: no
  timer-id: -1
  timers: {}
  views:
    opened: {}
    settings:
      open: no
  # datas part
  articles: {}
  settings: {}
  tags: []
  # datas inferred part
  titles: []

# ARTICLE BLOCK ##############################

Article =
  bar:
    text: ->
      #
      # TODO: generate text bar for article
      #
      a = 1
      #
  base:
    common: (id) -> title: "New article", ctxt: '', attrs: {}
    text: (id) ->
      article = Korrig.article.base.common id
      article.type = \text
      article
  close: (id) !->
    #
    # TODO: close an article
    #
    #
    Korrig.panel.refresh-list \rem, id
    #
  create: (side, type) !->
    #
    # TODO: create a new article
    #
    id = (new Date! .getTime!) + '-' + Korrig.article.get-id!
    ar = Korrig.article.base[type] id
    #
    console.log 'article'
    console.log ar
    #
    KorrigState.articles[id] = ar
    KorrigState.titles.push ar.title
    #
    KorrigState.views.opened[id] = status: \edit
    #
    # TODO: how to tell that this one is opened here?
    #
    # TODO: handle the article menu bar
    #
    Korrig.panel.refresh-list \add, id, ar.title
    Korrig.panel.swap side, \article
  gen-bar: (side, type) !->
    #
    # TODO: populate the article bar
    #
    a = 1
    #
  get-id: -> KorrigState.create-id += 1
  list: (side) !->
    #
    # TODO: show the current article list
    #
    a = q-sel '#kor-l-list-ctt'
    if KorrigState.titles.length is 0
      #
      console.log 'there is no articles'
      #
    #
    Korrig.panel.swap side, \list
  show: !->
    #
    # TODO
    #
    console.log 'show the article'
    #
  update: !->
    #
    # TODO: turned the currently showed article into edit mode
    #
    console.log 'edit the current article'
    #

# PANEL BLOCK ################################

Panel =
  init: -> { viewed: \list }
  open: (side, save = yes) !->
    for e in (q-sel "\#kor-#{side}-menu, \#kor-#{side}-content" yes)
      e.style.display = \flex
    q-sel "\#kor-#{side}" .classList.toggle \folded
    q-sel "\#kor-#{side}-tog" .setAttribute \hidden true
    if save then KorrigState.panel = side
  swap: (side, target) !->
    if target isnt KorrigState[side]
      if KorrigState[side].viewed isnt \none then tog "\#kor-#{side}-#{KorrigState[side].viewed}" off
      tog "\#kor-#{side}-#{target}" on
      KorrigState[side].viewed = target
  refresh-list: (type, id, txt = '') !->
    #
    # TODO: refresh the list of opened articles/view
    #
    switch type
      case \add
        if Object.keys KorrigState.views.opened .length is 1
          tog '#kor-r-select, #kor-l-select' on yes
        tt = txt + (if KorrigState.views.opened[id].status is \edit then ' (*)' else '')
        for s in [\l, \r] then q-sel "\#kor-#{s}-select" .append(c-elt \option, {value: id}, tt)
        #
        # TODO: moving to the new opened article?
        #
      case \rem
        #
        # TODO: remove the option
        #
        if Object.keys KorrigState.views.opened .length is 0
          tog '#kor-r-select, #kor-l-select' off yes
        #
        ids = "\#kor-l-select option[value=#{id}], \#kor-r-select option[value=#{id}]"
        for e in (q-sel ids) then e.remove!
        #
  tog: (side, halfed = no) !->
    for e in (q-sel "\#kor-#{side}-menu, \#kor-#{side}-content" yes)
      e.style.display = \none
    q-sel "\#kor-#{side}" .classList.toggle \folded
    q-sel "\#kor-#{side}-tog" .removeAttribute \hidden
    if not halfed then Korrig.panel.open (if side is \l then \r else \l)

# SAVE BLOCK #################################

Save =
  detect: !->
    if location.protocol.startsWith 'http'
      fetch location.pathname, { method: 'OPTIONS' }
        .then (res) ->
          if res.ok and res.headers.get 'dav'
            KorrigState.server-op: yes
            tog '#kor-mm-ul' on
            Korrig.notif-create \success 'Server detected' void 6_000
          else
            Korrig.notif-create \warning 'Warning! Failed to contact the save server'
        .catch (e) ->
          console.log 'Korrig error:'
          console.log e
          Korrig.notif-create \error 'Error on trying to contact the server'
  dl: !->
    attrs =
      href: 'data:text/html;charset:utf-8,' + encodeURIComponent Korrig.save.gen!
      #download: location.href.split '/' .pop!
      download: 'Korrig.html'
    e = c-elt \a, attrs
    document.body.appendChild e
    e.click!
    document.body.removeChild e
  gen: ->
    dt =
      app: q-sel \#hsm .textContent
      #data: q-sel \#hst .textContent
      data:
        {
          articles: KorrigState.articles
          settings: KorrigState.settings
          tags: KorrigState.tags
        } |> JSON.stringify
      font: q-sel \#hsf .outerHTML .substring 15 .replace '</defs>' ''
      mirror: q-sel \#hsi .textContent
      package:
        version: q-sel 'meta[name=version]' .content
        name: q-sel 'meta[name=application-name]' .content
      style: q-sel \#hms .textContent
    korrigHtml dt
  load: !->
    d = q-sel \#hst .textContent |> JSON.parse
    KorrigState.articles = d.articles
    KorrigState.settings = d.settings
    KorrigState.tags = d.tags
  put: !->
    fetch location.pathname, { method: \PUT, body: Korrig.save.gen! }
      .then (resp) ->
        resp.text!.then (txt) -> { ok: resp.ok, status: resp.status, text: txt }
      .then (res) ->
        if not res.ok
          throw(if res.text? then res.text else "Status: #{res.status}")
        else
          Korrig.notif-create \success 'Doc saved on the Server!'
      .catch (e) ->
        console.log 'Korrig error:'
        console.log e
        Korrig.notif-create \error 'Failed to save on the server!'

# SETTINGS BLOCK #############################

Settings =
  close: !->
    #
    # TODO: close the settings view
    #
    # TODO: what to swap to? Add this to settings
    #
    Korrig.panel.refresh-list \rem \settings
    #
  open: !->
    #
    # TODO: open the settings panel
    #
    if KorrigState.views.settings.open
      #
      # TODO: swap to show settings
      #
      console.log 'show opened settings'
      #
    else
      #
      #
      #
      KorrigState.views.settings.open = yes
      #
      #Korrig.panel.swap
      #
      Korrig.panel.refresh-list \add \settings \Settings
      #

# APP ########################################

Korrig =
  article: Article
  init: !->
    Korrig.save.load!
    #
    # TODO: load plugins
    #
    for initiator in KorrigState.inits then initiator!
    #
    for p in ["l", "r"] then KorrigState[p] = Panel.init!
    if document.body.clientWidth <= 980
      KorrigState.narrowed = yes
      Korrig.panel.tog \r yes
    addEventListener \resize, Korrig.resizing
    for e in (q-sel 'svg.font' yes) then e.setAttribute \viewBox '0 0 24 24'
    Korrig.save.detect!
    q-sel '\#kor-splash' .style.display = \none
  notif-create: (type = \info, text = void, html = void, tm = -1) !->
    id = Korrig.notif-get-id!
    attrs =
      class: "kor-notif-#type"
      title: 'Click to close'
      id: "kor-notif-#{id}"
      onclick:
        if tm is -1 then "Korrig.notifRem('\#kor-notif-#{id}')"
        else "Korrig.timerRun('#{id}')"
    if tm > -1
      KorrigState.timers["tm-#{id}"] =
        ctm: void
        fn: (id, silent = no) !->
          if silent then window.clearTimeout KorrigState.timers["tm-#{id}"].ctm
          Korrig.notifRem "\#kor-notif-#{id}"
          delete KorrigState.timers["tm-#{id}"]
    e = c-elt \div, attrs, text, html
    q-sel '#kor-notifs' .appendChild e
    if tm > -1 then KorrigState.timers["tm-#{id}"].ctm =
      window.setTimeout (!-> KorrigState.timers["tm-#{id}"]fn id), tm
  notif-get-id: -> KorrigState.notif-id += 1
  notif-rem: (id) !-> q-sel id .remove!
  panel: Panel
  resizing: !->
    if document.body.clientWidth <= 980
      if not KorrigState.narrowed
        KorrigState.narrowed = yes
        Korrig.panel.tog (if KorrigState.panel is \r then \l else \r), yes
    else
      if KorrigState.narrowed
        KorrigState.narrowed = no
        Korrig.panel.open (if KorrigState.panel is \r then \l else \r), no
  save: Save
  settings: Settings
  timer-get-id: -> KorrigState.timer-id += 1
  timer-run: (id) !-> KorrigState.timers["tm-#{id}"]fn id, yes

# EXPORT #####################################

window.KorrigState = KorrigState

window.Korrig = Korrig
