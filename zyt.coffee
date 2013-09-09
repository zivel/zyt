if Meteor.isClient
  @Times = new Meteor.Collection("times");

  if !Session.get('year')
    Session.set('year', parseInt((new Date).getFullYear()))

  host = 'interaction'
  key = 'blablo'
  user = {name: 'renato'}
  tzg = 80
  

  clearSettings()
  #saveSettings(host, key, user, tzg)
    
  
# Template Settings
  # Head
  Template.head.year = -> Session.get('year')

  Template.settings.notAllSet = -> 
    if Session.get('apiKey') && 
       Session.get('tzg') && 
       Session.get('miteHost') &&
       Session.get('editSettings') then false else true

if Meteor.isServer
  Meteor.startup ->