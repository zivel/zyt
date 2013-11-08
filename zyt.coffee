if Meteor.isClient
  @Times = new Meteor.Collection("times")

  if !Session.get('year')
    Session.set('year', parseInt((new Date).getFullYear()))

  Meteor.call "setYear", Session.get('year')

    
  if localStorage['apiKey'] && localStorage['miteHost']
    Meteor.call "checkKey", localStorage['apiKey'], localStorage['miteHost'], (err, response) ->
      if response
        share.saveToSession()
        updateAllTimes()
      else
        share.clearSettings() 

  updateAllTimes = () -> 
    start = new Date(Session.get('year'), 0, 1)
    end = new Date(Session.get('year'),11,31)
    user_id = JSON.parse(Session.get('user')).id
    while start <= end
      if @Times.find({date: start, user_id: user_id}).count() > 0
        current_day = @Times.findOne({date: start})
        day = current_day.day
      else
        day =
          date: start,
          ist: null,
          soll: share.getTargetTime(start),
          manual_soll: null,
          user_id: JSON.parse(Session.get('user')).id
          comment: null
        @Times.insert({date: day.date, user_id: day.user_id, day: day})
        console.log 'inserting'
      # get the time from mite and save it. when there is no entry in the db, it will be created (hence upsert not update)   
      Meteor.call "getMiteTimeByDay", localStorage['apiKey'], localStorage['miteHost'], day
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

    getMiteTimeByDay: (key, host, day) ->
          url = "https://#{host}.mite.yo.lk/time_entries.json"
          result = Meteor.http.call('GET', url, 
            params: 
              api_key: key, 
              at: day.date.yyyymmdd(), 
              user_id: day.user_id, 
              group_by: 'day'
          )
          # update the day entry with the ist time
          if result.data.length > 0
            day.ist = result.data[0].time_entry_group.minutes * 60
          # else if new Date() >= day.date
          #   day.ist = 0
          Times.update({date: day.date, user_id: day.user_id},{$set: {day: day}})
          console.log "updating #{day.date}"          
        
    # fillInTargetTime: (year = new Date().getFullYear(), force = false) ->
    #   console.log "going for #{year}"
    #   start = new Date(year, 0, 1)
    #   end = new Date(year,11,31)
    #   if Times.find(y: year).count() < 365 || force == true
    #     while start <= end
    #       targetMin = Meteor.call "addTargetTime", start     
    #       if Times.find({date: start}).count() == 0
    #           Times.insert({d: start.getDate(), m: start.getMonth(), y: year, date: start, soll: targetMin})
    #           console.log "writing #{start} = #{targetMin}"
    #       else
    #         Times.update(date: start, {$set: {d: start.getDate(), m: start.getMonth(), y: year, date: start, soll: targetMin}})
    #         console.log "updating #{start} = #{targetMin}"
    #       start.setDate(start.getDate() + 1)
    

  Meteor.startup ->
    # Meteor.call "fillInTargetTime", new Date().getFullYear(), true

    
