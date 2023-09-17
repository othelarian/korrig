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

# STORE ######################################

KorrigState =
  notif-id: -1
  panel: \left
  server-op: no

# APP ########################################

Korrig =
  init: !->
    console.log 'init Korrig App'
    Korrig.save-detect!
    #
    # TODO: move from splashscreen to panels
    #
    # TODO: load plugins
    #
    addEventListener \resize, Korrig.resizing
    #
    #a = q-sel 'svg.font' yes
    for e in (q-sel 'svg.font' yes) then e.setAttribute \viewBox '0 0 24 24'
    q-sel '\#kor-splash' .style.display = \none
  notif-create: (type = \info, text = void, html = void) !->
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
  resizing: !->
    #
    # TODO: handle resizing on panels
    #
    #console.log 'resizing occured'
    #
    t = 2
    #
  save-detect: !->
    if location.protocol.startsWith 'http'
      fetch location.pathname, { method: 'OPTIONS' }
        .then (res) ->
          if res.ok and res.headers.get 'dav'
            KorrigState.server-op: yes
            #
            # TODO: activate the button?
            #
            console.log 'save server ok'
            #
          else
            Korrig.notif-create \warning 'Warning! Failed to contact the save server'
        .catch (e) ->
          console.log 'Korrig error:'
          console.log e
          Korrig.notif-create \error 'Error on trying to contact the server'
  save-dl: !->
    attrs =
      href: 'data:text/html;charset:utf-8,' + encodeURIComponent Korrig.save-gen!
      #download: location.href.split '/' .pop!
      download: 'Korrig.html'
    e = c-elt \a, attrs
    document.body.appendChild e
    e.click!
    document.body.removeChild e
  save-gen: ->
    dt =
      app: q-sel '#hsm' .textContent
      data: q-sel '#hst' .textContent
      font: q-sel '#hsf' .outerHTML .substring 15 .replace '</defs>' ''
      mirror: q-sel '#hsi' .textContent
      package:
        version: q-sel 'meta[name=version]' .content
        name: q-sel 'meta[name=application-name]' .content
      style: q-sel '#hms' .textContent
    korrigHtml dt
  save-put: !->
    fetch location.pathname, { method: \PUT, body: Korrig.save-gen! }
      .then (resp) ->
        resp.text!.then (txt) -> { ok: resp.ok, status: resp.status, text: txt }
      .then (res) ->
        if not res.ok
          throw(if res.text? then res.text else "Status: #{res.status}")
        else
          #
          # TODO: do something to get that the file is now saved on the server
          #
          console.log 'everything\'s fine'
          #
      .catch (e) ->
        console.log 'Korrig error:'
        console.log e
        Korrig.notif-create \error 'Failed to save on the server!'

# EXPORT #####################################

window.KorrigState = KorrigState

window.Korrig = Korrig
