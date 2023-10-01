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

function tog s, t
  e = q-sel s
  if t then e.removeAttribute \hidden else e.setAttribute \hidden ''

# STORE ######################################

KorrigState =
  # functional part
  create-id: -1
  inits: []
  narrowed: no
  notif-id: -1
  opened: []
  panel: \l
  server-op: no
  # datas part
  articles: []
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
  create: (side, type) !->
    #
    # TODO: create a new article
    #
    id = Korrig.article.get-id!
    #
    #
    # TODO: add to KorrigState.opened
    #
    Korrig.panel.refresh-list!
    Korrig.panel.swap side, \article
  gen-bar: (side, type) !->
    #
    # TODO: populate the article bar
    #
    a = 1
    #
  get-id: !-> KorrigState.create-id += 1
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
  init: ->
    {
      viewed: \none
    }
  open: (side, save = yes) !->
    for e in (q-sel "\#kor-#{side}-menu, \#kor-#{side}-content" yes)
      e.removeAttribute \hidden
    q-sel "\#kor-#{side}" .classList.toggle \folded
    q-sel "\#kor-#{side}-tog" .setAttribute \hidden true
    if save then KorrigState.panel = side
  swap: (side, target) !->
    if target isnt KorrigState[side]
      if KorrigState[side].viewed isnt \none then tog "\#kor-#{side}-#{KorrigState[side].viewed}" off
      tog "\#kor-#{side}-#{target}" on
      KorrigState[side].viewed = target
  refresh-list: (type) !->
    #
    # TODO: refresh the list of opened articles/view
    #
    #switch type
      #
      #
    console.log 'update the panels list (both)'
    #
  tog: (side, halfed = no) !->
    for e in (q-sel "\#kor-#{side}-menu, \#kor-#{side}-content" yes)
      e.setAttribute \hidden true
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
            Korrig.notif-create \success 'Server detected'
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
      data: q-sel \#hst .textContent
      font: q-sel \#hsf .outerHTML .substring 15 .replace '</defs>' ''
      mirror: q-sel \#hsi .textContent
      package:
        version: q-sel 'meta[name=version]' .content
        name: q-sel 'meta[name=application-name]' .content
      style: q-sel \#hms .textContent
    korrigHtml dt
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
  open: !->
    #
    # TODO: open the settings panel
    #
    console.log 'settings not ready'
    #

# APP ########################################

Korrig =
  article: Article
  init: !->
    console.log 'init Korrig App'
    Korrig.save.detect!
    #
    # TODO: load datas
    #
    # TODO: load plugins
    #
    for initiator in KorrigState.inits then initiator!
    #
    KorrigState.l = Panel.init!
    KorrigState.r = Panel.init!
    #
    if document.body.clientWidth <= 980
      KorrigState.narrowed = yes
      Korrig.panel.tog \r yes
    addEventListener \resize, Korrig.resizing
    for e in (q-sel 'svg.font' yes) then e.setAttribute \viewBox '0 0 24 24'
    q-sel '\#kor-splash' .style.display = \none
  notif-create: (type = \info, text = void, html = void, tm = -1) !->
    id = Korrig.notif-get-id!
    attrs =
      class: "kor-notif-#type"
      title: 'Click to close'
      id: "kor-notif-#{id}"
      onclick: "Korrig.notifRem('\#kor-notif-#{id}')"
    e = c-elt \div, attrs, text, html
    q-sel '#kor-notifs' .appendChild e
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

# EXPORT #####################################

window.KorrigState = KorrigState

window.Korrig = Korrig
