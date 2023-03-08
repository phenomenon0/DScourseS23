library(tidyverse)
library(jsonlite)
system('wget -O dates.json https://www.vizgr.org/historical-events/search.php?format=json&begin_date=00000101&end_date=20230209&lang=en')
system('cat dates.json')
mylist <- fromJSON('dates.json')
mybdf <- bind_rows(mylist$result[-1])
class(mybdf$dates) 
head(mybdf, 5)

