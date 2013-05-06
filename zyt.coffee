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

  Date.prototype.yyyymmdd = ->
    yyyy = this.getFullYear().toString()
    mm = (this.getMonth()+1).toString()
    dd  = this.getDate().toString()
    # uncomment if you need leading zeros before month and days
    # yyyy + '-' + if mm[1] then mm else "0"+mm[0] + '-' + if dd[1] then dd else "0"+dd[0]
    yyyy + '-' + mm + '-' + dd

  months = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember']

  Template.mite.user = ->
    this.user = JSON.parse localStorage['user']
    
  Template.body.key = -> Session.get 'key'
  
  Template.calendar.months = ->
    months

  Template.days.val = ->
    Meteor.call 'getTime', localStorage['apiKey'], localStorage['miteHost'], '2013-05-3', JSON.parse(localStorage['user']).id, (err, response) ->
      result = JSON.parse(response.content)
      console.log result[0].time_entry_group.minutes
      console.log (new Date).yyyymmdd()

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
      Meteor.http.call('GET', url, 
        params:
          api_key: key,
      )
    getTime: (key, host, date, userId) ->
      url = "https://#{host}.mite.yo.lk/time_entries.json"
      bla = Meteor.http.call('GET', url,
        params:
          api_key: key,
          at: date,
          user_id: userId
          group_by: 'day'
      )
    
      
      

  Meteor.startup ->
    # code to run on server at startup
    