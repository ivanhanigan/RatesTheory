
# dl
#popkahn <- read.dta('http://www.stata-press.com/data/r9/popkahn.dta')
#popkahn        
        
#kahn <- read.dta('http://www.stata-press.com/data/r9/kahn.dta')
#kahn

  download.file('http://www.stata-press.com/data/r9/popkahn.dta', destfile = 'data/popkahn.dta', mode = 'wb')

  download.file('http://www.stata-press.com/data/r9/kahn.dta', destfile = 'data/kahn.dta', mode = 'wb')
