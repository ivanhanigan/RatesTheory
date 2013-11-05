
#######################################################################
# name: do-dstdize
# studypops        
d <- read.table('http://data.princeton.edu/eco572/datasets/preston21long.dat', col.names = c('country', 'ageg', 'pop', 'deaths'))
head(d)
 
# standard
standard<- ddply(d, 'ageg', function(df) return(c(pop=sum(df$pop))))

# epitools needs single
do <- subset(d, country == 'Sweden')   # Kazakhstan
ageadjust.direct(count=do$deaths, pop=do$pop, stdpop=standard$pop)     
        
rageadjust.direct <- function (data, count, pop, rate = NULL, stdpop, by, using = NA,print=T, time = NULL, conf.level = 0.95, age = 'age'){

if (!require(plyr)) install.packages('plyr', repos='http://cran.csiro.au'); require(plyr)
d <- data
studysite <- by
standard <- using
agevar <- age

if (missing(count) == TRUE & !missing(pop) == TRUE & is.null(rate) == TRUE) {
d$count <- d[,rate] * d[,pop]
}
if (missing(pop) == TRUE & !missing(count) == TRUE & is.null(rate) == TRUE) {
d$pop <- d[,count]/d[,rate]
}
if (is.null(rate) == TRUE & !missing(count) == TRUE & !missing(pop) == TRUE) {
d$rate <- d[,count]/d[,pop]
}
alpha <- 1 - conf.level

if(is.null(time)){
        observed<-ddply(d, c(studysite), function(df) return(c(observed = sum(df[,count]), pop = sum(df[,pop]), crude.rate = sum(df[,count])/sum(df[,pop])))) 
        standard$stdwt <- standard[,stdpop]/sum(standard[,stdpop])
        d<- merge(d,standard, by = age) 
        dsr <- ddply(d, by, function(df) return(c(dsr = sum(df$stdwt * df$rate))))
        names(d) <- gsub(paste(pop,'.x',sep=''), pop, names(d))
        dsr.var <- ddply(d, by, function(df) return(c(dsr.var = sum((df$stdwt^2) * (df[,count]/df[,pop]^2))))) 
        wm <- ddply(d, by, function(df) return(c(wm=max(df$stdwt/df[,pop]))))
        dsr<-merge(dsr, dsr.var, by = by)
        dsr<-merge(dsr, wm, by = by)

        gamma.lci <- ddply(dsr, by, function(df) 
                return(c(lci=qgamma(alpha/2, shape = (df$dsr^2)/df$dsr.var, scale = df$dsr.var/df$dsr)
                )))
        gamma.uci <- ddply(dsr, by, function(df) 
                return(c(uci=qgamma(1 - alpha/2, shape = ((df$dsr + df$wm)^2)/(df$dsr.var + df$wm^2), scale = (df$dsr.var + df$wm^2)/(df$dsr + df$wm))
                )))
        dsr<-merge(dsr, gamma.lci, by = by)
        dsr<-merge(dsr, gamma.uci, by = by)
        names(dsr) <- gsub('dsr', 'adj.rate', names(dsr)) 
        outdat <- merge(observed,dsr[,c('country','adj.rate','lci','uci')])
} else {
observed<-ddply(d, c(studysite, time), function(df) return(c(observed = sum(df[,count]), pop = sum(df[,pop]), crude.rate = sum(df[,count])/sum(df[,pop])))) 
standard$stdwt <- standard[,stdpop]/sum(standard[,stdpop])
d<- merge(d,standard, by = age) 
dsr <- ddply(d, c(by, time), function(df) return(c(dsr = sum(df$stdwt * df$rate))))
names(d) <- gsub(paste(pop,'.x',sep=''), pop, names(d))
dsr.var <- ddply(d, c(by, time), function(df) return(c(dsr.var = sum((df$stdwt^2) * (df[,count]/df[,pop]^2))))) 
wm <- ddply(d, c(by, time), function(df) return(c(wm=max(df$stdwt/df[,pop]))))
dsr<-merge(dsr, dsr.var, by = c(by, time))
dsr<-merge(dsr, wm, by = c(by, time))

gamma.lci <- ddply(dsr, c(by, time), function(df) 
        return(c(lci=qgamma(alpha/2, shape = (df$dsr^2)/df$dsr.var, scale = df$dsr.var/df$dsr)
        )))
gamma.uci <- ddply(dsr, c(by, time), function(df) 
        return(c(uci=qgamma(1 - alpha/2, shape = ((df$dsr + df$wm)^2)/(df$dsr.var + df$wm^2), scale = (df$dsr.var + df$wm^2)/(df$dsr + df$wm))
        )))
dsr<-merge(dsr, gamma.lci, by = c(by, time))
dsr<-merge(dsr, gamma.uci, by = c(by, time))
names(dsr) <- gsub('dsr', 'adj.rate', names(dsr)) 
outdat <- merge(observed,dsr[,c(by, time,'adj.rate','lci','uci')])

}
return(outdat)          
}

rageadjust.direct(data = d, age ='ageg', count='deaths', pop='pop', stdpop='pop', using=standard, by = 'country')     

d$day <- c(rep(1,19),rep(2,19))
d$studysite <- 'allTheSame'
rageadjust.direct(data = d, age ='ageg', count='deaths', pop='pop', stdpop='pop', using=standard, by = 'studysite', time = 'day')
