if Meteor.isClient

	Days = new Meteor.Collection(null)

#Session Stuff
	if !Session.get('year')
		console.log 'setze jahr'
		Session.set('year', parseInt((new Date).getFullYear()))
	
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
		console.log 'clear'
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


# Time Stuff
	Date.prototype.yyyymmdd = ->
    yyyy = this.getFullYear().toString()
    mm = (this.getMonth()+1).toString()
    dd  = this.getDate().toString()
    # uncomment if you need leading zeros before month and days
    # yyyy + '-' + if mm[1] then mm else "0"+mm[0] + '-' + if dd[1] then dd else "0"+dd[0]
    yyyy + '-' + mm + '-' + dd
	
	getMiteTime = (date = (new Date).yyyymmdd()) ->
		Meteor.call 'getTime', localStorage['apiKey'], localStorage['miteHost'], date, JSON.parse(localStorage['user']).id, (err, response) ->
			result = JSON.parse(response.content)
			if result.length > 0
				ist = result[0].time_entry_group.minutes * 60
				Days.update({date: date}, {$set: {ist: ist}})

# Template Stuff
	Template.calendar.months = ->	Calendar()
	
	# make a function here
	# Template.calendar.miteTime = ->
	# 	last_day = new Date(Session.get('year'),month+1,0)
	# 	days = [1..(last_day.getDate())]



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
		else if event.target.id == 'lastyear'
			Session.set('year',parseInt(Session.get('year')) - 1 )

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