if Meteor.isClient
  @Times = new Meteor.Collection("times");

  if !Session.get('year')
    Session.set('year', parseInt((new Date).getFullYear()))
  
  if localStorage['apiKey'] && localStorage['miteHost']
    Meteor.call "checkKey", localStorage['apiKey'], localStorage['miteHost'], (err, response) ->
      if response
        share.saveToSession()
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
          $("#settings").addClass('in')
        else
          share.clearSettings()


if Meteor.isServer
    Meteor.methods
      checkKey: (key, host) ->
        url = "https://#{host}.mite.yo.lk/myself.json"
        Meteor.http.call('GET', url, 
          params:
            api_key: key
        )
  Meteor.startup ->