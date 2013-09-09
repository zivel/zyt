saveSettings = (host, key, user, tzg) ->
  localStorage['apiKey'] = key
  localStorage['miteHost'] = host
  localStorage['user'] = JSON.stringify user 
  localStorage['tzg'] = parseInt(tzg,10)
  Session.set 'apiKey', key
  Session.set 'miteHost', host
  Session.set 'user', JSON.stringify user
  Session.set 'tzg', parseInt(tzg,10)
  Session.set 'editSettings', true

clearSettings = ->
  localStorage.removeItem 'apiKey'
  localStorage.removeItem 'miteHost'
  localStorage.removeItem 'user'
  localStorage.removeItem 'tzg'
  Session.set 'apiKey', undefined
  Session.set 'miteHost', undefined
  Session.set 'user', undefined
  Session.set 'tzg', undefined
