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
#- - - - - 
# read word freq file ----
# -----------------
word.frq <- read.csv("/root/WorkR/word_frq.csv") %>% 
    arrange(desc(freq))

# -------------------------------------
# -------- sentiment analysis ---
# --------------------------------------
user.info.sent.message.table <- read.csv("/root/WorkR/user_info_message_table_376.csv")
user.info.sent.message.table$timestamp <-as.Date(user.info.sent.message.table$timestamp, format="%Y-%m-%d %H:%M:%S") 
user.info.sent.message.table$timestamp <-as.POSIXct.Date(user.info.sent.message.table$timestamp)
user.info.sent.message.table$message <- vkR::clear_text(user.info.sent.message.table$message, patterns = list("[|]\\w+"))

library(stringi)
bad.words <- c("\n", "\t" )
stri_replace_all_fixed(user.info.sent.message.table$message, bad.words, '', vectorize_all=FALSE)


# before plot compute
v.limits = seq(0, length(user.info.sent.message.table$number), 25)
v.labels <- as.Date.character(user.info.sent.message.table$timestamp[v.limits])


