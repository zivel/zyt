if Meteor.isClient
  @Times = new Meteor.Collection("times");

  if !Session.get('year')
    Session.set('year', parseInt((new Date).getFullYear()))

  Meteor.call "fillDB", Session.get('year'), localStorage['apiKey']

#Session Stuff
  if localStorage['apiKey'] && localStorage['miteHost']
    Meteor.call "checkKey", localStorage['apiKey'], localStorage['miteHost'], (err, response) ->
      if response
        Session.set 'apiKey', localStorage['apiKey']
        Session.set 'miteHost', localStorage['miteHost'] 
        Session.set 'user', localStorage['user']
        Session.set 'tzg', localStorage['tzg']
        Session.set 'editSettings', true
      else
        clearSettings() 

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

  collapsSettings = ->
    if allSet() && Session.get('editSettings')
      false
    else
      true
  
  allSet = ->
    if Session.get('apiKey') && Session.get('tzg') && Session.get('miteHost')
      true
    else
      false

  fillMite = ->
    console.log Session.get('year')
    end = new Date(Session.get('year'),11,31)
    daysOfYear = []
    start = new Date(Session.get('year'), 0, 1)

    while start <= end
      Meteor.call 'getMiteTimeByDay', localStorage['apiKey'], localStorage['miteHost'], start.yyyymmdd(), JSON.parse(localStorage['user']).id, (err, response) ->
        result = JSON.parse(response.content)
        if result.length > 0
          zeit = result[0].time_entry_group.minutes

          # day = result[0].time_entry_group.day
          # hours = Math.floor(zeit / 60)
          # minutes = zeit % 60
          # Session.set(day,"#{hours}:#{minutes}")
        
      start.setDate(start.getDate() + 1)
    
    

# Time Stuff
  Date.prototype.yyyymmdd = ->
    yyyy = this.getFullYear().toString()
    mm = (this.getMonth()+1).toString()
    dd  = this.getDate().toString()
    "#{yyyy}-#{if mm[1] then mm else "0"+mm[0]}-#{if dd[1] then dd else "0"+dd[0]}"
  
# Template Stuff
  Template.calendar.months = -> Calendar()
  
  Template.calendar.miteTime = ->
    Session.get(this.yyyymmdd())
  
  Template.calendar.helpers day: ->
    this.getDate()

  Template.head.current = ->
    current =
      year: Session.get('year'),
      nextyear: Session.get('year') + 1,
      lastyear: Session.get('year') - 1

  Template.settings.apiKey = -> Session.get('apiKey')
  Template.settings.tzg = -> Session.get('tzg')
  Template.settings.miteHost = -> Session.get('miteHost')
  Template.settings.user = -> JSON.parse Session.get('user')
  Template.settings.notAllSet = -> collapsSettings()
  
# all click events in the head
  Template.head.events "click button": (event, template) ->
    if event.target.id == 'saveSettings'
      event.preventDefault()
      Meteor.call "checkKey", $("#apiKey").val(), $("#miteHost").val(), (err, response) ->
        if response
          Session.set('key', localStorage['apiKey'])  
          saveSettings $("#miteHost").val(), $("#apiKey").val(), response.data.user, $("#tzg").val()
        else
          clearSettings()
    else if event.target.id == 'nextyear'
      Session.set('year',parseInt(Session.get('year')) + 1 )
      fillMite()
    else if event.target.id == 'lastyear'
      Session.set('year',parseInt(Session.get('year')) - 1 )
      fillMite()

# Calendar view  
  Calendar = () ->
    months = (month for month in [0..11])
    Month month, Session.get('year') for month in months

  Month = (month) ->
    monthsArr = ["Januar", "Februar", "März", "April",
                "Mai", "Juni", "Juli", "August",
                "September", "Oktober", "November",
                "Dezember"]
    first_day = new Date(Session.get('year'),month,1)
    last_day_last_month = new Date(Session.get('year'),month,0)
    last_day = new Date(Session.get('year'),month+1,0)
    
    days = [1..(last_day.getDate())]
    days_before = if first_day.getDay() == 1 then [] else [(last_day_last_month.getDate() - (last_day_last_month.getDay() - 1))..(last_day_last_month.getDate())]
    days_after = if last_day.getDay() == 0 then [] else [1..(last_day.getDay() - 7)*-1]
    
    dates = []
    dates.push(new Date(Session.get('year'), month, d)) for d in days
    
    m = 
      dates: dates
      days_before: days_before
      days_after: days_after
      name: monthsArr[first_day.getMonth()]
      empty_line: true unless days.length + days_before.length + days_after.length == 42
  
  
  # fillMite()

if Meteor.isServer
  Times = new Meteor.Collection("times");

  Meteor.methods
      checkKey: (key, host) ->
        url = "https://#{host}.mite.yo.lk/myself.json"
        Meteor.http.call('GET', url, 
          params:
            api_key: key
        )
      getMiteTimeByDay: (key, host, date, userId) ->
        url = "https://#{host}.mite.yo.lk/time_entries.json"
        Meteor.http.call('GET', url, 
          params: 
            api_key: key, 
            at: date, 
            user_id: userId, 
            group_by: 'day'
        )

      fillDB: (year, apiKey) ->
        start = new Date(year, 0, 1)
        end = new Date(year,11,31)
        if Times.find(y: year, apiKey: apiKey).count() < 365
          while start <= end
            if Times.find({date: start, apiKey: apiKey}).count() == 0
              Times.insert({d: start.getDate(), m: start.getMonth(), y: year, date: start, ist: 0, soll: 0, apiKey: apiKey})
            else
              Times.update(date: start, apiKey: apiKey, {$set: {d: start.getDate(), m: start.getMonth(), y: year, date: start, ist: 0, soll: 0, apiKey: apiKey}})
            start.setDate(start.getDate() + 1)
        
  Meteor.startup ->
  # code to run on server at startup