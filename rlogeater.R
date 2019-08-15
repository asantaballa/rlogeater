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
            #, RequestParms = str_split(Start.Payload.requestInfo," ")
            #, RequestParms_Command = str_split(Start.Payload.requestInfo," ",simplify=TRUE)[,1]
            #, RequestParms_Url = str_split(Start.Payload.requestInfo," ",simplify=TRUE)[,2]
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
            , Duration = difftime(End.Timestamp, Start.Timestamp)
            , RequestParms_Command = str_split(Start.Payload.requestInfo," ",simplify=TRUE)[,1]
            , RequestParms_Url = str_split(Start.Payload.requestInfo," ",simplify=TRUE)[,2]
            )


cb2xxx <- cb[order(-cb$Duration),]
cbe <-  mutate( cb
              , DurHSecs = as.integer(Duration * 100)
              )

#cbx <- cbe %>% select(RequestParms)

cbef <- filter(cbe, Duration > 1.0)

ggplot(cbe, aes(x = DurHSecs)) + geom_bar()

##

x0 <- transmute(cb
               , Payload.correlationId = Payload.correlationId
               , Start.Payload.requestInfo = Start.Payload.requestInfo
               )  
x1 <- mutate(x0,
             s = str_split(Start.Payload.requestInfo," ")
             ) 
x2 <- unlist(x1, recursive = FALSE)
#x2s <- filter(x2, FALSE)
#x2r <- relist(x2)
x3 <- lapply(x1, unlist)
#x4 <- mutate(x1, u = unlist(s))
#view(x2)
