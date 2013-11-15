# Calendar view  
  share.Calendar = () ->
    months = (month for month in [0..11])
    console.log 'hi'
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