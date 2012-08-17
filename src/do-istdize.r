
#######################################################################
# name: do-istdize

popkahn <- read.dta('http://www.stata-press.com/data/r9/popkahn.dta')
popkahn        
        
kahn <- read.dta('http://www.stata-press.com/data/r9/kahn.dta')
kahn



#for(st in c('California', 'Maine')){
# st <- 'Maine'
# print(st)        
do <- subset(kahn, state == 'Maine')   
# note needs counts for each age, but Main only has death in first row
do$death <- do$death[1]        
print(ageadjust.indirect(count=do$death/length(do$death), pop=do$population, stdcount = popkahn$deaths, stdpop=popkahn$population))
#}
