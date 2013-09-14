share.saveSettings = (host, key, user, tzg=100) ->
  localStorage['apiKey'] = key
  localStorage['miteHost'] = host
  localStorage['user'] = JSON.stringify user 
  console.log tzg
  if tzg == '' || tzg == 'NaN'
    tzg = 100
  localStorage['tzg'] = parseInt(tzg,10)
  share.saveToSession()

share.clearSettings = ->
  localStorage.removeItem 'apiKey'
  localStorage.removeItem 'miteHost'
  localStorage.removeItem 'user'
  localStorage.removeItem 'tzg'
  Session.set 'apiKey', undefined
  Session.set 'miteHost', undefined
  Session.set 'user', undefined
  Session.set 'tzg', undefined

share.saveToSession = ->
  Session.set 'apiKey', localStorage['apiKey']
  Session.set 'miteHost', localStorage['miteHost']
  Session.set 'user', localStorage['user']
  Session.set 'tzg', localStorage['tzg']
  
