if Meteor.isClient
  @Times = new Meteor.Collection("times")

  if !Session.get('year')
    Session.set('year', parseInt((new Date).getFullYear()))

  Meteor.call "setYear", Session.get('year')
  
  if localStorage['apiKey'] && localStorage['miteHost']
    Meteor.call "checkKey", localStorage['apiKey'], localStorage['miteHost'], (err, response) ->
      if response
        share.saveToSession()
        start = new Date(Session.get('year'), 0, 1)
        end = new Date(Session.get('year'),11,31)
        while start <= end
          day =
            date: start,
            ist: null,
            soll: share.getTargetTime(start),
            manual_soll: null,
            user_id: JSON.parse(Session.get('user')).id
            comment: null
          
          # check if day is in db
          if @Times.find({date: start, user_id: JSON.parse(Session.get('user')).id}).count() == 0
            @Times.insert({day})
            console.log 'day does not exist!'
          else
            console.log 'day exists!'
          # console.log day

          # if is read out db and check if complete
          #    if mite missing
          #       get mite time
          #    if soll missing
          #       get soll time
          #    save to db
          # else
          #   get mite time
          #   get soll time
          #   save to db
          # return day
          start.setDate(start.getDate() + 1)

      else
        share.clearSettings() 

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
    Meteor.call "fillInTargetTime", Session.get('year')

if Meteor.isServer
  Times = new Meteor.Collection("times")

  Meteor.methods
    checkKey: (key, host) ->
      url = "https://#{host}.mite.yo.lk/myself.json"
      Meteor.http.call('GET', url, 
        params:
          api_key: key
      )
    # addTargetTime: (date) ->
    #   share.getTargetTime(date)
    getMiteTimeByDay: (key, host, date, userId) ->
        url = "https://#{host}.mite.yo.lk/time_entries.json"
        Meteor.http.call('GET', url, 
          params: 
            api_key: key, 
            at: date, 
            user_id: userId, 
            group_by: 'day'
        )
    # fillInTargetTime: (year = new Date().getFullYear(), force = false) ->
    #   console.log "going for #{year}"
    #   start = new Date(year, 0, 1)
    #   end = new Date(year,11,31)
    #   if targetTimes.find(y: year).count() < 365 || force == true
    #     while start <= end
    #       targetMin = Meteor.call "addTargetTime", start     
    #       if targetTimes.find({date: start}).count() == 0
    #           targetTimes.insert({d: start.getDate(), m: start.getMonth(), y: year, date: start, soll: targetMin})
    #           console.log "writing #{start} = #{targetMin}"
    #       else
    #         targetTimes.update(date: start, {$set: {d: start.getDate(), m: start.getMonth(), y: year, date: start, soll: targetMin}})
    #         console.log "updating #{start} = #{targetMin}"
    #       start.setDate(start.getDate() + 1)
    

  Meteor.startup ->
    # Meteor.call "fillInTargetTime", new Date().getFullYear(), true

    
