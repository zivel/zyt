if Meteor.isClient
  
  saveSettings = (host, key, user) ->
    localStorage['apiKey'] = key
    localStorage['miteHost'] = host
    localStorage['user'] = JSON.stringify user   
    Session.set 'key', key

  clearSettings = ->
    localStorage.removeItem 'apiKey'
    localStorage.removeItem 'miteHost'
    localStorage.removeItem 'user'
    Session.set 'key', undefined
  
  easterSunday = (year = (new Date).getFullYear()) ->
    a = year % 19
    b = ~~(year / 100)
    c = year % 100
    d = ~~(b / 4)
    e = b % 4
    f = ~~((b + 8) / 25)
    g = ~~((b - f + 1) / 3)
    h = (19 * a + b - d - g + 15) % 30
    i = ~~(c / 4)
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = ~~((a + 11 * h + 22 * l) / 451)
    n = h + l - 7 * m + 114
    month = ~~(n / 31)
    day = (n % 31) + 1
    [month, day]

  month = ''

  Template.mite.user = ->
    console.log localStorage['user']
    this.user = JSON.parse localStorage['user']
    
  Template.body.key = -> Session.get 'key'
  

  Template.mite.events
    'click #optout': ->
      clearSettings()
  
  Template.settings.events
     'submit': (event, template) ->
        event.preventDefault()
        Meteor.call "checkKey", $("#apiKey").val(), $("#miteHost").val(), (err, response) ->
          if response.headers.status is '200 OK'
            saveSettings $("#miteHost").val(), $("#apiKey").val(), response.data.user
          else
            clearSettings()

  Session.set 'key', localStorage['apiKey'] if localStorage['apiKey']


     
if Meteor.isServer
  Meteor.methods
    checkKey: (key, host) ->
      url = "https://#{host}.mite.yo.lk/myself.json"
      bla = Meteor.http.call('GET', url, 
        params:
          api_key: key,
      )

  Meteor.startup ->
    # code to run on server at startup
    