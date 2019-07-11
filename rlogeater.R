library("tidyverse")
library("RJSONIO")
library("rlist")

# lflat <- function(l){
#   ret <- unlist(l)
#   return(ret)
# }
# 
# ldf <- function(l){
#   ret <- as.data.frame(l)
#   return(ret)
# }

filename = "/Users/albertosantaballa/Dropbox/data/Elogs sample/ETOOWebApiLogv2.20190522.1.txt"

json <- read_file(filename)
json <- paste("[", json, "]")
rawFromJson <- fromJSON(json)
rm(json)
rawFromJson <- rawFromJson[-857]  # -- Remove null entry

l2 <- unlist(rawFromJson, recursive = TRUE, use.names = TRUE)
l2b <- unlist(rawFromJson[1], use.names = TRUE)
d2b <- as.data.frame(l2b)
# d2 <- as.data.frame(l2)

l3 <- lapply(rawFromJson, unlist)
#d3 <- as.data.frame(l3)

l4 <- do.call(c, unlist(rawFromJson, recursive=FALSE))

l5 <- unlist(rawFromJson, recursive = TRUE, use.names = TRUE)
d5 <- do.call(rbind, lapply(rawFromJson, as.data.frame))

l6 <- map(rawFromJson, flatten)

# l7 <- lapply(rawFromJson, lflat)
# l7.1 <- l7[1][[1]]
# l7.2 <- l7[2][[1]]
# l7b <- lapply(l7, ldf)

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
      , Payload.correlationId = map(., "Payload.correlationId")  
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

#--

n0 <- names(flatList[[1]])
n1 <- lapply(flatList, names)
n1u <- unlist(n1) 
n1uu <- unique(n1u)
n1uul <- as.list(n1uu)
#view(n1uu)

n2 <- flatList[[1]]
n2n <- names(n2)
