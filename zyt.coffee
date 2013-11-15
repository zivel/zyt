if Meteor.isClient
  Times = new Meteor.Collection("times")

  if !Session.get('year')
    Session.set('year', parseInt((new Date).getFullYear()))

  Meteor.call "setYear", Session.get('year')

    
  if localStorage['apiKey'] && localStorage['miteHost']
    Meteor.call "checkKey", localStorage['apiKey'], localStorage['miteHost'], (err, response) ->
      if response
        share.saveToSession()
        updateAllTimes(true)
      else
        share.clearSettings() 

  updateAllTimes = (force=false) -> 
    start = new Date(Session.get('year'), 0, 1)
    end = new Date(Session.get('year'),11,31)
    user_id = JSON.parse(Session.get('user')).id
    while start <= end
      if Times.find({date: start, user_id: user_id}).count() > 0
        current_day = Times.findOne({date: start, user_id: user_id})
        if force
          day = current_day.day
          day.soll = share.getTargetTime(start)
          Times.update({_id: current_day._id},{$set: {day: day}})
        else
          day = current_day.day
      else
        day =
          date: start,
          ist: null,
          soll: share.getTargetTime(start),
          manual_soll: null,
          user_id: JSON.parse(Session.get('user')).id
          comment: null
        Times.insert({date: day.date, user_id: day.user_id, day: day})
        console.log 'inserting'
      start.setDate(start.getDate() + 1)
  
# Template Settings
  # Head
  Template.head.year = -> Session.get('year')

  Template.settings.tzg = -> Session.get('tzg')
  Template.settings.miteHost = -> Session.get('miteHost')
  Template.settings.apiKey = -> Session.get('apiKey')
  Template.settings.user = -> JSON.parse Session.get('user')
  Template.settings.allSet = -> 
    if Session.get('apiKey') && 
       Session.get('tzg') && 
       Session.get('miteHost') then true else false

  Template.calendar.months = -> share.Calendar()

  Template.day.helpers 
    dayNr: ->
      this.getDate()
    miteTime: ->
      user = Session.get('user')
      if user
        user_id = JSON.parse(user).id
        DBday = Times.findOne({date: this, user_id: user_id})
      if DBday
      # get the time from mite and save it. when there is no entry in the db, it will be created (hence upsert not update)   
        Meteor.call "getMiteTimeByDay", localStorage['apiKey'], localStorage['miteHost'], DBday
        hours = Math.floor(DBday.day.ist / 3600)
        minutes = Math.floor(DBday.day.ist /60) % 60
        seconds = DBday.day.ist % 60
        "#{hours}h#{minutes}m#{seconds}s"
      else
        '...'
    sollZeit: ->
      user = Session.get('user')
      if user
        day = Times.findOne({date: this, user_id: JSON.parse(user).id})
      if day
        hours = Math.floor(day.day.soll / 3600)
        minutes = Math.floor(day.day.soll /60) % 60
        seconds = day.day.soll % 60
        "#{hours}h#{minutes}m#{seconds}s"
      else
        '...'    
    diffTime: ->
      user = Session.get('user')
      if user
        day = Times.findOne({date: this, user_id: JSON.parse(user).id})
      if day
        diff = day.day.ist - day.day.soll
        "#{diff}"
        # hours = Math.floor(diff / 3600)
        # minutes = Math.floor(diff /60) % 60
        # seconds = diff % 60
        # "#{hours}h#{minutes}m#{seconds}s"

  Handlebars.registerHelper "diffColor", (diffTime) ->
    if diffTime >= 0
      "text-success"
    else
      "text-error"

  Template.day.rendered = ->
    $('.icon-info-sign').popover()

  # Calendar()
  
# all click events in the head
  Template.head.events "click button": (event, template) ->
    if event.target.id == 'saveSettings'
      event.preventDefault()
      Meteor.call "checkKey", $("#apiKey").val(), $("#miteHost").val(), (err, response) ->
        if response
          console.log response
          share.saveSettings $("#miteHost").val(), $("#apiKey").val(), response.data.user, $("#tzg").val()
        else
          share.clearSettings()
    else if event.target.id == 'nextyear'
      Session.set('year',parseInt(Session.get('year')) + 1 )
    else if event.target.id == 'lastyear'
      Session.set('year',parseInt(Session.get('year')) - 1 )
    updateAllTimes()

if Meteor.isServer
  Times = new Meteor.Collection("times")

  Meteor.methods
    checkKey: (key, host) ->
      url = "https://#{host}.mite.yo.lk/myself.json"
      Meteor.http.call('GET', url, 
        params:
          api_key: key
      )

    addTargetTime: (date) ->
      share.getTargetTime(date)

    getMiteTimeByDay: (key, host, DBday, force=false) ->
          if (DBday.day.ist == null or force == true) and new Date() >= DBday.date
            url = "https://#{host}.mite.yo.lk/time_entries.json"
            result = Meteor.http.call('GET', url, 
              params: 
                api_key: key, 
                at: DBday.date.yyyymmdd(), 
                user_id: DBday.user_id, 
                group_by: 'day'
            )
            # update the day entry with the ist time
            if result.data.length > 0
              DBday.day.ist = result.data[0].time_entry_group.minutes * 60
            else
              DBday.day.ist = 0
            Times.update({_id: DBday._id},{$set: {day: DBday.day}})
            console.log "updating #{DBday.date} (#{DBday._id}) width #{DBday.day.ist}"  
          
    
  Meteor.startup ->
    # Meteor.call "fillInTargetTime", new Date().getFullYear(), true

    
