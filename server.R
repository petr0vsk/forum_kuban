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
     ggplot(subset(word.frq, freq>640), aes (word, freq))
     + geom_bar(stat="identity")   
     + theme(axis.text.x=element_text(angle=45, hjust=1))   
 )
    
  
}) #=========================
