easterSunday = (year = (new Date).getFullYear()) ->
  a = year % 19
  b = ~~(year / 100)
  c = year % 100
  d = ~~(b / 4)
  e = b % 4
  f = ~~((b + 8) / 25)
  g = ~~((b - f + 1) / 3)
  h = (19 * a + b - d - g + 15) % 30
  i = ~~(c / 4)
  k = c % 4
  l = (32 + 2 * e + 2 * i - h - k) % 7
  m = ~~((a + 11 * h + 22 * l) / 451)
  n = h + l - 7 * m + 114
  month = ~~(n / 31)
  day = (n % 31) + 1
  new Date("#{year}.#{month}.#{day}")

sechsileuten = (year = (new Date).getFullYear()) ->
  thrMon = getNthDayOfMonth(year, 4, 1, 3)
  if new Date(easterSunday(year).getTime() + (3600000*24)).ddmm() == "#{thrMon}.4"
    "#{thrMon+7}.4"
  else if new Date(easterSunday(year).getTime() - (6*3600000*24)).ddmm() == "#{thrMon}.4" || year == '2015' # for some reason 2015 is different...
    "#{thrMon-7}.4"
  else
    "#{thrMon}.4"

getNthDayOfMonth = (year, month, day, number) ->
  first = new Date year, month-1, 1
  day_of_week = first.getDay()
  ((number-1)*7+1) + ((7+day) - day_of_week) % 7

knabenschiessen = (year = (new Date).getFullYear()) ->  
  knSun = getNthDayOfMonth(year, 9, 0, 2)
  "#{knSun+1}.9"

Date.prototype.ddmm = ->
  mm = (this.getMonth()+1).toString()
  dd  = this.getDate().toString()
  "#{dd}.#{mm}"
    
Date.prototype.yyyymmdd = ->
  yyyy = this.getFullYear().toString()
  mm = (this.getMonth()+1).toString()
  dd  = this.getDate().toString()
  "#{yyyy}-#{if mm[1] then mm else "0"+mm[0]}-#{if dd[1] then dd else "0"+dd[0]}"

share.getTargetTime = (d = new Date()) ->
  freeDays = ['1.1', '2.1', '1.5', '1.8', '25.12', '26.12']
  halfDays = []
  es = easterSunday(d.getFullYear())
  freeDays.push new Date(es.getTime() - (2*3600000*24)).ddmm() #Oster Freitag
  freeDays.push new Date(es.getTime() + (3600000*24)).ddmm() #Oster Montag
  freeDays.push new Date(es.getTime() + (39*3600000*24)).ddmm() #Auffahrt
  freeDays.push new Date(es.getTime() + (50*3600000*24)).ddmm() #PfingstMontag
  halfDays.push sechsileuten(d.getFullYear()) 
  halfDays.push knabenschiessen(d.getFullYear())
  # no work on sunday and saturday
  if d.getDay() == 0 || d.getDay() == 6 
    return 0
  else if d.ddmm() in freeDays
    return 0
  else if d.ddmm() in halfDays
    42*60*60/5/2 
  else
    42*60*60/5
