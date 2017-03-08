# -------------------------------------------
# Analise great kuban forum topik about MTS
# petr0vskyj.aleksander@gmail.com
# --------------------------------------------
rm(list = ls())
library(tidyr)
library(dplyr)
library(rvest)
library(stringr)
library(RSelenium)
library(RMySQL)
library(tm)
library(reshape2)
library(slam)
library(tidytext)
library(wordcloud)
library(tibble)
library(SnowballC)
library(ggplot2)
library(cluster) 


# read scrapping file
user.info.message.table <- read.csv("/root/WorkR/user_info_message_table3.csv", stringsAsFactors = FALSE)
txt <- VectorSource(user.info.message.table$message)
#ovid <-VCorpus(txt)
ovid <- VCorpus(txt, readerControl = list(language="ru"))

ovid <- tm_map(ovid, content_transformer(tolower))
ovid <- tm_map(ovid, removeWords, stopwords(kind="ru"))
ovid <- tm_map(ovid, removeWords, stopwords(kind="en"))
ovid <- tm_map(ovid, removePunctuation)
ovid <-tm_map(ovid, removeNumbers)
ovid <- tm_map(ovid, stripWhitespace)
ovid <- tm_map(ovid, stemDocument)
# save corpus 
saveRDS(ovid, file="ovid.rda")
#---make DTM ---
DTM <- DocumentTermMatrix(ovid)
DTM.sparce <- removeSparseTerms(DTM, 0.95)
saveRDS(DTM, file="DTM.rds")
# terms by frequency
#-#freq.dtm <- colSums(as.matrix(DTM))
#-#freq.dtm.ord <- order(freq.dtm)
#-#saveRDS(freq.dtm, file="/root/WorkR/freq_dtm.rds")
#-#saveRDS(freq.dtm.ord, file="/root/WorkR/freq_dtm_ord.rds")
#- - - - - 
freq.dtm <- readRDS("/root/WorkR/freq_dtm.rds")
freq.dtm.ord <- readRDS("/root/WorkR/freq_dtm_ord.rds")
freq.dtm[tail(freq.dtm.ord, 100)]
#word.frq <- data.frame(word=names(freq.dtm), freq=freq.dtm)
#write.csv(word.frq, "/root/WorkR/word_frq.csv")
word.frq <- read.csv("/root/WorkR/word_frq.csv")

