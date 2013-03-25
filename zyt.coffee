class Mite
  constructor: ->
    console.log 'building up...'
    @apiKey = @constructor.ask4key()
    
  @host = "https://interaction-enabling.mite.yo.lk"

  @ask4key: ->
    #TODO: read key from cookie ask for key save key
    if !@apiKey
      @apiKey = "f853eed9533860a"
    else
      console.log "key is #{@apiKey}"

  getTimeFor: (day) ->
    #TODO
  @getTotalTime: (groupBy) ->
    Meteor.call "fetchTime", 
      "#{@host}/time_entries.json",
      params:
        group_by: groupBy
        api_key: @apiKey
      (error, result) ->
      hier ist der bug!  # Session.set ('result',result)



if Meteor.isClient
  mite = new Mite
  Template.hello.greeting = ->
    "Welcome to zyt"

  Template.hello.years = ->
    Mite.getTotalTime ("year")
    
  Template.hello.meep = ->
    bla = Mite.getTotalTime ("year")
    

  Template.hello.events "click input": ->
    
    # template data, if any, is available in 'this'
    console.log "You pressed the button"  if typeof console isnt "undefined"

if Meteor.isServer
  Meteor.methods fetchTime: (url, params) ->
    url = url
  
    #synchronous GET
    result = Meteor.http.get(url,params)
    if result.statusCode is 200
      respJson = JSON.parse(result.content)
      console.log "response received."
      respJson
    else
      console.log "Response issue: ", result.statusCode
      errorJson = JSON.parse(result.content)
      throw new Meteor.Error(result.statusCode, errorJson.error)

  Meteor.startup ->
    # code to run on server at startup