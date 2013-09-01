if Meteor.isClient

#Session Stuff
	if !Session.get('year')
		Session.set('year', (new Date).getFullYear())
	
	if localStorage['apiKey'] && localStorage['miteHost']
		Meteor.call "checkKey", localStorage['apiKey'], localStorage['miteHost'], (err, response) ->
			if response
				Session.set('key', localStorage['apiKey'])	
				saveSettings $("#miteHost").val(), $("#apiKey").val(), response.data.user, $("#tzg").val()
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
	
	clearSettings = ->
		console.log 'clear'
		console.log Session.get('tzg')
		localStorage.removeItem 'apiKey'
		localStorage.removeItem 'miteHost'
		localStorage.removeItem 'user'
		localStorage.removeItem 'tzg'
		Session.set 'apiKey', undefined
		Session.set 'miteHost', undefined
		Session.set 'user', undefined
		Session.set 'tzg', undefined

# Template Stuff
	Template.calendar.months = ->
    	months = Calendar()
    	months

    Template.head.current = ->
    	current =
    		year: Session.get('year'),
    		nextyear: Session.get('year') + 1,
    		lastyear: Session.get('year') - 1

    
    Template.settings.tzg = -> Session.get('tzg')
    Template.settings.miteHost = -> Session.get('miteHost')

	Template.head.events "click button": (event, template) ->
		if event.srcElement.id == 'saveSettings'
			event.preventDefault()
			Meteor.call "checkKey", $("#apiKey").val(), $("#miteHost").val(), (err, response) ->
				if response
					saveSettings $("#miteHost").val(), $("#apiKey").val(), response.data.user, $("#tzg").val()
				else
				 	clearSettings()
		else
			console.log event.srcElement
			Session.set('year',parseInt(event.srcElement.value))

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

		m = 
			days: days
			days_before: days_before
			days_after: days_after
			name: monthsArr[first_day.getMonth()]
			empty_line: true unless days.length + days_before.length + days_after.length == 42		
		
if Meteor.isServer
	Meteor.methods
    	checkKey: (key, host) ->
      		url = "https://#{host}.mite.yo.lk/myself.json"
      		Meteor.http.call('GET', url, 
        		params:
          			api_key: key
      		)

	Meteor.startup ->
  # code to run on server at startup