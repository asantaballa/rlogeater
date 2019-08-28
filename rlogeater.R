library("tidyverse")
library("RJSONIO")
library("rlist")
library("dplyr")
library("lubridate")
library("urltools")

op <- options(digits.secs=3)

filename = "/Users/albertosantaballa/Dropbox/data/Elogs sample/ETOOWebApiLogv2.20190522.1.txt"

jsontext <- read_file(filename)
jsontext <- paste("[", jsontext, "]")
rawFromJson <- fromJSON(jsontext)
#rm(jsontext)
rawFromJson <- rawFromJson[-857]  # -- Remove null entry

flatList <- lapply(rawFromJson, unlist)

cookedBase <- flatList %>%  {
  tibble(
        ProviderId = map(., "ProviderId")
      , EventId = map(., "EventId")  
      , Keywords = map(., "Keywords")  
      , Level = map(., "Level")  
      , Message = map(., "Message")  
      , Opcode = map(., "Opcode")  
      , Task = map(., "Task")  
      , Version = map(., "Version")  
      , Payload.correlationId = as.character(map(., "Payload.correlationId"))  
      , Payload.requestInfo = map(., "Payload.requestInfo")  
      , Payload.responseInfo = map(., "Payload.responseInfo")  
      , Payload.headers = map(., "Payload.headers")  
      , Payload.responseCode = map(., "Payload.responseCode")  
      , EventName = map(., "EventName")  
      , Timestamp = map(., "Timestamp")  
      , ProcessId = map(., "ProcessId")  
      , ThreadId = map(., "ThreadId")  
  )
}

cookedBase <- as.data.frame((cookedBase))

cbStartsSelect <- filter(cookedBase, EventId == 3)
cbStarts <-
  transmute ( cbStartsSelect
            , Payload.correlationId = Payload.correlationId
            , Start.Payload.requestInfo = Payload.requestInfo
            , Start.Timestamp = ymd_hms(Timestamp)
            )

cbOthersSelect <- filter(cookedBase, EventId != 3)
cbOthers <-
  transmute ( cbOthersSelect
            , Payload.correlationId = Payload.correlationId
            , End.Payload.responseInfo = Payload.responseInfo
            , End.Timestamp = ymd_hms(Timestamp)
            )

cb <- mutate( inner_join(cbStarts, cbOthers)
            , DurSec = as.numeric(difftime(End.Timestamp, Start.Timestamp))
            , DurSec100th = as.integer(DurSec * 100)
            , DurSec10th = as.integer(DurSec * 10)
            , RequestParms_Command = str_split(Start.Payload.requestInfo," ",simplify=TRUE)[,1]
            , RequestParms_Url = str_split(Start.Payload.requestInfo," ",simplify=TRUE)[,2]
            , domain = urltools::domain(RequestParms_Url)
            , path = urltools::path(RequestParms_Url)
)


cbOrderHigh <- cb[order(-cb$ DurSec),]

cbAvgByApi <- cb %>% 
              group_by(RequestParms_Url) %>% 
              summarize(durAvg = mean(DurSec)) 

cbef <- filter(cb, DurSec > 1.0)

#ggplot(cb, aes(x = DurSec100th)) + geom_bar()
ggplot(cb, aes(path,  y=DurSec))  + geom_point() + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))


