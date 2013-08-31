if Meteor.isClient

	Template.calendar.months = ->
    months = Calendar()
    console.log months
    months


	Calendar = (year = (new Date).getFullYear()) ->
		months = (month for month in [0..11])
		Month month, year for month in months
				
	Month = (month,year) ->
		monthsArr = ["Januar", "Februar", "März", "April",
			          "Mai", "Juni", "Juli", "August",
			          "September", "Oktober", "November",
			          "Dezember"]
		first_day = new Date(year,month,1)
		last_day_last_month = new Date(year,month,0)
		last_day = new Date(year,month+1,0)
		
		days = [1..(last_day.getDate())]
		days_before = if first_day.getDay() == 1 then [] else [(last_day_last_month.getDate() - (last_day_last_month.getDay() - 1))..(last_day_last_month.getDate())]
		days_after = if last_day.getDay() == 0 then [] else [1..(last_day.getDay() - 7)*-1]

		m = 
			days: days
			days_before: days_before
			days_after: days_after
			name: monthsArr[first_day.getMonth()]

  # Template.hello.events
  #   'click input' : ->
  #     # template data, if any, is available in 'this'
  #     if typeof console !== 'undefined'
  #       console.log "You pressed the button"
  

if Meteor.isServer
  Meteor.startup ->
  # code to run on server at startup