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
  server-op: no

# APP ########################################

Korrig =
  init: !->
    console.log 'init Korrig App'
    Korrig.save-detect!
  notif-create: (type = \info, text = void, html = void) !->
    #
    # TODO: dev ok, test not done yet
    #
    attrs =
      class: "kor-notif-#type"
      title: 'Click to close'
      id: KorrigState.notif-get-id!
      onclick: "Korrig.notifRem(\#kor-notif-#{attrs.id})"
    c-elt \div, attrs, text, html
  notif-get-id: -> KorrigState.notif-id += 1
  notif-rem: (id) !-> q-sel id .remove!
  save-detect: !->
    #
    # TODO: detect if the app is on a save server
    #
    if location.protocol.startsWith 'http'
      #
      # TODO: what is root?
      #
      fetch location.pathname, { method: 'OPTIONS' }
        .then res ->
          if res.ok and res.headers.get 'dav'
            KorrigState.server-op: yes
            #
            # TODO: activate the button?
            #
          else
            Korrig.notif-create \warning 'Warning! Failed to contact the save server'
        .catch e ->
          console.log 'Korrig error:'
          console.log e
          Korrig.notif-create \error 'Error on trying to contact the server'
  save-dl: !->
    attrs =
      href: 'data:text/html;charset:utf-8,' + encodeURIComponent Korrig.save-gen!
      download: location.href.split '/' .pop!
    e = c-elt \a, attrs
    document.body.appendChild e
    e.click!
    document.body.removeChild e
  save-gen: ->
    dt =
      app: q-sel '#hsm' .textContent
      data: q-sel '#hst' .textContent
      mirror: q-sel '#hsi' .textContent
      package:
        version: q-sel 'meta[name=version]' .content
        name: q-sel 'meta[name=application-name]' .content
      style: q-sel '#hms' .textContent
    korrigHtml dt
  save-put: !->
    #
    # TODO: trigger the sending to the server
    #
    fetch location.pathname, { method: \PUT, body: Korrig.save-gen! }
      .then resp ->
        #
        resp.text!.then txt -> { ok: resp.ok, status: resp.status, text: txt }
        #
      .then res ->
        #
        if not res.ok
          #
          console.log 'do somethin'
          #
        else
          #
          console.log 'everything\'s fine'
          #
        #
      .catch e ->
        console.log 'Korrig error:'
        console.log e
        Korrig.notif-create \error 'Failed to save on the server!'

# EXPORT #####################################

window.KorrigState = KorrigState

window.Korrig = Korrig
