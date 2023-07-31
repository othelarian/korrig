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

# APP ########################################

Korrig =
  init: !->
    console.log 'this is the init'
    #
    # TODO: make a true init
    #
    # TODO: detect if there's a server to save
    #
    if location.protocol.startsWith 'http'
      fetch root, { method: 'OPTIONS' }
        .then res ->
          #
          if res.ok and res.headers.get 'dav'
            #
            console.log 'res ok, dav ok'
            #
          else
            #
            #
            console.log 'cannot save on the server'
            #
      #
      # TODO
      #
      console.log 'fetching...'
      #
    #
  notify: (content) !->
    #
    # TODO: create and show the notification
    #
    #
    console.log 'create a notification'
    #
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
    c = Korrig.save-gen!
    #

window.Korrig = Korrig
