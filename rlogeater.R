library("tidyverse")
library("RJSONIO")
library("rlist")
library("dplyr")

filename = "/Users/albertosantaballa/Dropbox/data/Elogs sample/ETOOWebApiLogv2.20190522.1.txt"

jsontext <- read_file(filename)
jsontext <- paste("[", jsontext, "]")
rawFromJson <- fromJSON(jsontext)
#rm(json)
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

cookedBaseStarts <- filter(cookedBase, EventId == 3)
cookedBaseStarts <-
  transmute(cookedBaseStarts
            , Payload.correlationId = Payload.correlationId
            , Start.Payload.requestInfo = Payload.requestInfo
            , Start.Timestamp = Timestamp
  )

cookedBaseOthers <- filter(cookedBase, EventId != 3)
cookedBaseOthers <-
  transmute (cookedBaseOthers
            , Payload.correlationId = Payload.correlationId
            , End.Payload.responseInfo = Payload.responseInfo
            , End.Timestamp = Timestamp
            )

cookedMerged <- cookedBaseStarts
cookedMerged <-inner_join(cookedMerged, cookedBaseOthers)


