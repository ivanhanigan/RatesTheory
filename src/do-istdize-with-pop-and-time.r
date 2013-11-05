
#######################################################################
# name: do-istdize-with-pop-and-time
# rewrite with by studypop and time

rageadjust.indirect <- function (data, count, pop, using, stdcount, stdpop, stdrate = NULL, conf.level = 0.95, by, time = NULL){
        if (!require(plyr)) install.packages('plyr', repos='http://cran.csiro.au'); require(plyr)
        # count can either be age specific if known for study pops or a total deaths if unknown (in which case should be a fraction that sums to the total)
        d <- data
        studysite <- by
        standard <- using

        # if both have a col called death and population the combined names will have.x or .y so rename first
        names(standard) <- gsub(stdcount, paste(stdcount,'Std',sep=''), names(standard))
        names(standard) <- gsub(stdpop, paste(stdpop,'Std',sep=''), names(standard))
        d <- merge(d,standard, all.x=T, by = 'age')

        zv <- qnorm(0.5 * (1 + conf.level))

        if(is.null(time)){
                observed<-ddply(d, c(studysite), function(df) return(c(observed = sum(df[,count]), pop = sum(df[,pop]), crude.rate = sum(df[,count])/sum(df[,pop])))) 
                # NOT DONE YET
                # if (is.null(stdrate) == TRUE & length(stdcount) > 1 & length(stdpop > 
                        # 1)) {
                        # stdrate <- stdcount/stdpop
                # }
                expected <- ddply(d, c(studysite), function(df) return(c(stdcrate=sum(df[, paste(stdcount,'Std',sep='')])/sum(df[,paste(stdpop,'Std',sep='')]), expected = sum((df[, paste(stdcount,'Std',sep='')]/df[,paste(stdpop,'Std',sep='')]) * df[,pop])))) 
        } else {

                observed<-ddply(d, c(studysite, time), function(df) return(c(observed = sum(df[,count]), pop = sum(df[,pop]), crude.rate = sum(df[,count])/sum(df[,pop])))) 
                expected <- ddply(d, c(studysite, time), function(df) return(c(stdcrate=sum(df[, paste(stdcount,'Std',sep='')])/sum(df[,paste(stdpop,'Std',sep='')]), expected = sum((df[, paste(stdcount,'Std',sep='')]/df[,paste(stdpop,'Std',sep='')]) * df[,pop])))) 

        }

        outdat <- merge(observed, expected)
        outdat$sir <- outdat$observed/outdat$expected
        outdat$logsir.lci <- log(outdat$sir) - zv * (1/sqrt(outdat$observed))
        outdat$logsir.uci <- log(outdat$sir) + zv * (1/sqrt(outdat$observed))
        outdat$sir.lci <- exp(outdat$logsir.lci)
        outdat$sir.uci <- exp(outdat$logsir.uci)
        outdat$adj.rate <- outdat$sir * outdat$stdcrate
        outdat$adj.rate.lci <- outdat$sir.lci * outdat$stdcrate
        outdat$adj.rate.uci <- outdat$sir.uci * outdat$stdcrate
        if(is.null(time)){
        outdat <- outdat[,c(studysite,'observed','expected','sir','sir.lci','sir.uci','crude.rate','adj.rate','adj.rate.lci','adj.rate.uci')]
        } else {
        outdat <- outdat[,c(studysite,time,'observed','expected','sir','sir.lci','sir.uci','crude.rate','adj.rate','adj.rate.lci','adj.rate.uci')]
        }        
        return(outdat)
}


# standard
popkahn <- read.dta('http://www.stata-press.com/data/r9/popkahn.dta')
popkahn        
# studypops        
kahn <- read.dta('http://www.stata-press.com/data/r9/kahn.dta')
kahn
# note needs counts for each age, but Main only has death in first row     
kahn[kahn$state == 'Maine','death'] <- 11051
kahn
# need to create the fraction of deaths in the age groups for this example to work
kahn$count <- kahn$death/(length(kahn$death)/length(table(kahn$state)))

rageadjust.indirect(data=kahn, by = 'state', time = NULL, using = popkahn, count='count', pop='population', stdcount = 'deaths', stdpop='population')


# check orig
do <- subset(kahn, state == 'Maine')   

ageadjust.indirect(count=do$death/length(do$death), pop=do$population, stdcount = popkahn$deaths, stdpop=popkahn$population)

rage <- rageadjust.indirect(data=do, by = 'state', time = NULL, using = popkahn, count='count', pop='population', stdcount = 'deaths', stdpop='population')

as.data.frame(t(rage[1,]))
