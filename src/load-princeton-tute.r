
###########################################################################
# newnode: load-princeton-tute

  # dl
  download.file('http://data.princeton.edu/eco572/datasets/preston21long.dat', destfile = 'data/preston21long.dat', mode = 'wb')
   # load
   d <- read.table('http://data.princeton.edu/eco572/datasets/preston21long.dat', col.names = c('country', 'ageg', 'pop', 'deaths'))
   write.csv(d, 'data/preston21long.csv', row.names = F)
   
   # check
   head(d)
   png('reports/ageRates.png', res = 100)
   with(subset(d, country == 'Sweden'), plot((deaths/pop)*1000, log = 'y', type = 'l', col='blue'))
   with(subset(d, country == 'Kazakhstan'), lines((deaths/pop)*1000, col='red'))
   legend('bottomright', c('Kazakhstan','Sweden'), lty = 1, col = c('red','blue'))
   dev.off()
