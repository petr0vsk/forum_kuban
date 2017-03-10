#------------------------------------------------------
# Aleksander Petrovskii
# petr0vskjy.aleksander@gmail.com
#-----------------------------------------------------

library(shiny)
library(ggplot2)

shinyServer(function(input, output) {

output$mts.table = DT::renderDataTable({user.info.message.table[ ,input$show_fields, drop=FALSE]}, 
                                       rownames = FALSE,
                                       class = 'cell-border stripe',
                                       filter = 'top', #изменить типы столбцов фрейма http://rstudio.github.io/DT/б
                                       extensions = 'KeyTable',
                                       options = list(searchHighlight = TRUE,
                                                      keys = TRUE
                                       #??# dom = 'Bfrtip',
                                       #??# buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
                                       )
                                            
    )
output$barplot<- renderPlot(
    ggplot((word.frq %>% slice(1:input$freq.range)), aes (word, freq))+ 
        geom_bar(stat="identity") + 
        labs(title = "Highest frequency words", x = NULL, y = "Word frequency") +
        coord_flip()
 )
# график сентимент-анализа по времени   
output$sentimentplot <- renderPlot(
    ggplot(  (user.info.sent.message.table %>% slice(1:input$sentiment.range))  , aes(x = number, y=sent)) + 
        geom_bar(na.rm=TRUE, stat="identity", position="identity", colour="darkblue") +
        stat_smooth(colour="green", na.rm=TRUE) +
        ggtitle("Use theme(plot.title = element_text(hjust = 0.5)) to center") +
        theme(plot.title = element_text(hjust = 0.5)) +
        ggtitle("График эмоций в сообщениях форума МТС") +
        scale_x_discrete(limits=v.limits) + 
        #scale_x_continuous(breaks = v.limits, labels = v.labels) +
        ylab("Значение эмоциональной оценки") +
        xlab("Номер сообщения")
)
  
}) #=========================
