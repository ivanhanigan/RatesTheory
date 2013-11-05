
###########################################################################
# newnode: init
if (!require(reshape)) install.packages('reshape', repos='http://cran.csiro.au'); require(reshape)
if (!require(plyr)) install.packages('plyr', repos='http://cran.csiro.au'); require(plyr)
if (!require(ggplot2)) install.packages('ggplot2', repos='http://cran.csiro.au'); require(ggplot2)
if (!require(stringr)) install.packages('stringr', repos='http://cran.csiro.au'); require(stringr)
if (!require(lubridate)) install.packages('lubridate', repos='http://cran.csiro.au'); require(lubridate)
if (!require(epitools)) install.packages('epitools', repos='http://cran.csiro.au'); require(epitools)
if (!require(foreign)) install.packages('foreign', repos='http://cran.csiro.au'); require(foreign)

####
# init additional directories for project management
source('~/Dropbox/tools/analysisTemplate.r')
analysisTemplate()
