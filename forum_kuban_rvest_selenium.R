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
#library(qdap)


# Sys.setlocale(category = "LC_CTYPE", locale = "ru_RU.UTF-8")
# ---- open session on kuban forum to rvest -------
link.to.first.page <- "http://forums.kuban.ru/f1043/mts_-_chast-_120_a-4314457.html"
session <- html_session(link.to.first.page, encoding = "UTF-8")

#-------------------------------------------------------------------------------------------------------------
#--- Let`s navigate to first page of forum topic, 
#--- and make list of links to all topic`s 'links.to.all.topics'
#------------------------------------------------------------------------------------------------------------
forum.page <- read_html(session, encoding = "UTF-8")
links.to.the.page.topic <- forum.page %>%
    html_nodes(xpath = "//*/div[@class='pagenav']/a")%>%
    html_attr("href")
end.of.links <- 1
links.to.all.topics <-list()
links.to.all.topics <-c(links.to.all.topics, link.to.first.page)
i= 1
while (!is.na(end.of.links))  {
    links.to.all.topics <- c(links.to.all.topics, links.to.the.page.topic)
    links.to.the.page.topic <- jump_to(session, links.to.the.page.topic[[(length(links.to.the.page.topic)-1)]][1]) %>%
        read_html(encoding = "UTF-8")%>%
        html_nodes(xpath = "//*/div[@class='pagenav']/a") %>%
        html_attr("href")
    # is string "Последняя (Last)" on the page? 
    end.of.links <- links.to.the.page.topic[[(length(links.to.the.page.topic)-1)]][1] %>%
        read_html(encoding = "UTF-8")%>%
        html_nodes(xpath = "//*/div[@class='pagenav']/a") %>%
        html_text()%>%
        str_extract("Последняя")%>%
        last()
    print(end.of.links)
    print(i)
    i <- i+1
}
links.to.all.topics <- c(links.to.all.topics, links.to.the.page.topic)
#  get link`s from last page 
links.to.the.page.topic <- jump_to(session, links.to.the.page.topic[[(length(links.to.the.page.topic))]][1]) %>%
    read_html()%>%
    html_nodes(xpath = "//*/div[@class='pagenav']/a") %>%
    html_attr("href")
# and now get list of all link`s to the topic
links.to.all.topics <- c(links.to.all.topics, links.to.the.page.topic) %>%
    unique()

# ---- open session on kuban forum to RSelenium -------
# Run a server for example using Docker
# docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.1

require(RSelenium)


remDr <- remoteDriver(remoteServerAddr = "localhost" 
                      , port = 4445L
                      , browserName = "firefox"
)
remDr$open()

user.info.message.table <- data_frame()
for (i in 1:length(links.to.all.topics)){
    ##for (i in 1:3){
    print(i)
    print(links.to.all.topics[i])
    remDr$navigate((as.character(links.to.all.topics[i])) )
    #remDr$findElements(using = 'xpath', value = "//*/table[@id='post']")
    forum.page <-read_html(remDr$getPageSource()[[1]])
    topic.table <- forum.page %>% # ::rvest work with html_tables better than ::Rselenium
        html_nodes(xpath = "//*/table[@id='post']")%>%
        html_table(trim =T, fill=T, header = NA)
    user.info <- topic.table[[1]]$X1
    user.message <- topic.table[[1]]$X2
    user.info.message <- data.frame(user.info,user.message)
    
    # correct duplicate row with quote
    correct.row <- !is.na(user.info.message[,2])
    user.info.message <- user.info.message[correct.row, ]
    user.info.message.table <- rbind(user.info.message.table, user.info.message)
    #user.info.message.table <-c(user.info.message.table, user.info.message)
}
#delete row wthis advertisting which contains word "Объявление"
user.info.message.table[grep("Объявление", user.info.message.table$user.message),] <- NA
user.info.message.table <- na.omit(user.info.message.table)
delete <- which(grepl("Объявление", user.info.message.table$user.message))
delete.advertising <-  user.info.message.table[grep("Объявление", user.info.message.table$user.message),] 
write.csv(user.info.message.table, "/root/WorkR/user_info_message_table.csv")
# == transform first col in to two columns with nikname and timestamp of user.message ==
user.name <-list()
user.name.temp <- list()
number.of.message <- list()
number.of.message.temp <- list()
date.time <-list()
message.date <- list()
message.time <- list()

for (i in 1:nrow(user.info.message.table)){
    user.name.temp <- str_split(user.info.message.table$user.info[i], "\n")[[1]][1]
    number.of.message.temp <- str_split(user.name.temp, " ")[[1]][4]
    user.name.temp <- str_split(user.name.temp, " ")[[1]][1]
    number.of.message <- c(number.of.message, number.of.message.temp)
    user.name <- (c(user.name, user.name.temp))
    date.time <- str_split(user.info.message.table$user.info[i], "\n")[[1]][4]
    date.time <- str_split(date.time, "-")
    message.date.temp <- str_trim(date.time[[1]][2])
    message.date <- c(message.date, message.date.temp)
    message.time.temp <- str_trim(date.time[[1]][3])
    message.time <- c(message.time, message.time.temp)
}

user.info.message.table$user.name <- unlist(user.name)
user.info.message.table$number.of.message <- unlist(number.of.message)
user.info.message.table$message.time <- unlist(message.time)
user.info.message.table$message.date <- unlist(message.date)
# make right order of column`s
user.info.message.table <- select(user.info.message.table, number.of.message, message.date, message.time, user.name, user.message)
# save temp result
colnames(user.info.message.table) <- c("number", "date", "time", "name", "message")
#user.info.message.table <- read.csv("/root/WorkR/user_info_message_table2.csv", header = T)
rownames(user.info.message.table) <- 1:nrow(user.info.message.table)
user.info.message.table$timestamp <-str_c(user.info.message.table$date, user.info.message.table$time, sep = " ")
user.info.message.table$date <- NULL
user.info.message.table$time <- NULL
user.info.message.table$timestamp <- strptime(user.info.message.table$timestamp, "%d.%m.%Y %H:%M")
user.info.message.table <-select(user.info.message.table, number, timestamp, name, message)
user.info.message.table$name <- as.character(user.info.message.table$name)
user.info.message.table$message <- as.character(user.info.message.table$message)
#user.info.message.table$date <- as.Date(user.info.message.table$date, format = "%d.%m.%Y")

write.csv(user.info.message.table, "/root/WorkR/user_info_message_table3.csv")
#---- close connection ----
remDr$close()
selServ$stop()


# =============================
connDB <-dbConnect(MySQL(),
                   user = 'root',
                   #password = '34times34',
                   host = '127.0.0.1',
                   dbname = 'mts'
)
dbGetInfo(connDB)
dbListTables(connDB)
dbWriteTable(connDB, name = 'mts_table', value = user.info.message.table, overwrite=TRUE)

dbDisconnect(connDB)

#--#
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

#---make DTM ---
DTM <- DocumentTermMatrix(ovid)
DTM.sparce <- removeSparseTerms(DTM, 0.95)
# terms by frequency
freq.dtm <- colSums(as.matrix(DTM))
freq.dtm.ord <- order(freq.dtm)
freq.dtm[tail(freq.dtm.ord, 100)]
word.frq <- data.frame(word=names(freq.dtm), freq=freq.dtm)
#save word freq frame
write.csv(user.info.message.table, "/root/WorkR/word-freq_mts_1.csv")
#-------------
p <- ggplot(subset(word.frq, freq>640), aes (word, freq))
p <- p + geom_bar(stat="identity")   
p <- p + theme(axis.text.x=element_text(angle=45, hjust=1))   
p   
plot.new()
wordcloud(names(freq.dtm), freq.dtm, min.freq = 640)
plot.new()
wordcloud(names(freq.dtm), freq.dtm, max.words=50, rot.per=0.2, scale=c(5, .1), colors=brewer.pal(6, "Dark2"))
plot.new()
library(cluster)   
d <- dist(t(DTM.sparce), method="euclidian")   
fit <- hclust(d=d, method="ward.D2")   
plot(fit, hang=-1)   
plot.new()
plot(fit, hang=-1)
groups <- cutree(fit, k=5)   # "k=" defines the number of clusters you are using   
rect.hclust(fit, k=4, border="red") # draw dendogram with red borders around the 5 clusters   

library(fpc)
plot.new()
d <- dist(t(DTM.sparce), method="euclidian")   
kfit <- kmeans(d, 3)   
clusplot(as.matrix(d), kfit$cluster, color=T, shade=T, labels=2, lines=0)   

#=========================================================
TDM <- TermDocumentMatrix(ovid)

freq_term <- findFreqTerms(TDM, 200)
findAssocs(TDM, "мтс", 0.2)
inspect(TDM[1:10, 1:10])

plot(TDM)
# внимание! ресурсоемко!
TDM.matrix <- as.matrix((TDM))
frec <- sort(colSums(TDM.matrix), decreasing = T)
head(frec,20)
TCF <- data.frame(Term=colnames(TDM.matrix))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               tf <- data.frame(term = names(frec), freq = freq)
head(tf,20)
# with DTM
#-------------------
TDM.common <- removeSparseTerms(TDM, 0.95)
inspect(TDM.common[1:4, 1:20])

s_v <- get_sentences(user.info.message.table$message)
sentiment_vector <- get_sentiment(s_v, method="nrc")
plot(sentiment_vector, type="l", main="Plot Trajectory", xlab = "Narrative Time", ylab= "Emotional Valence")
s1 <- "плохой гадкий мальчик"
sv1 <- get_sentiment(s1, method = "afinn")


Sys.setenv(TENSORFLOW_PYTHON="/usr/bin/python3")
library(tensorflow)
sess = tf$Session()
hello <- tf$constant('Hello, TensorFlow!')
sess$run(hello)



