#------------------------------------------------------------------
# Aleksander Petrovskii
# petr0vskjy.aleksander@gmail.com
#----------------------------------------------------------------- 

library(shiny)
library(shinydashboard)

dashboardPage(
    dashboardHeader(title = "kuban.forum.ru"),
    dashboardSidebar(
        sidebarMenu(
                        menuItem("MTS",     tabName = "mts", icon = icon("mobile")),
                        menuItem("Beeline", tabName = "beeline", icon = icon("forumbee")),
                        menuItem("Tele2",   tabName = "tele2", icon = icon("podcast")),
                        menuItem("Megafon", tabName = "megafon", icon = icon("phone"))
        )
        
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "mts",
# ---------- Graphics ----------------------------------------
                    fluidRow(
                        tabBox(
                            title = "Graphics", width = 12,
                            # The id lets us use input$tabset1 on the server to find the current tab
                            id = "tabset1", height = "450px",
                            tabPanel("Barplot", "First tab content",  plotOutput("barplot")),
                            tabPanel("Clust",    "Tab content 2"),
                            tabPanel("Wordcloud", "World cloud")
                        )
                        
                    ),
                    
                    
  #-------- Select field`s ----------------------------------------------------------------------------------------------------                  
                    fluidRow(
                        box(
                            title = "Select fields for message tables", width = 12, solidHeader = TRUE, status = "primary",
                            collapsible = TRUE,
                            checkboxGroupInput(
                                "show_fields",
                                "Select field`s of topic's:",
                                names(user.info.message.table),
                                selected = c("number", "timestamp","name","message" ),
                                inline = TRUE
                            )
                        )
                        
                    ),
                    
    #---- Message Table ----------------------------------------------------------------------------------------------------                
                    
                    fluidRow(
                        tabBox(
                            title = tagList(shiny::icon("table"), "Message table"),
                            width = 12, 
                            tabPanel("All user's topic MTS", 
                                     DT::dataTableOutput("mts.table")
                            ),
                            tabPanel("Custom user's topic", "Custom user'smessage will be here")
                            
                        )
                    )
                
            ),
        tabItem(tabName = "beeline",
                h2("Beeline")
            
           ),
        tabItem(tabName = "tele2",
                h2("Tele2")
            
           ),
        tabItem(tabName = "megafon",
                h2("Megafon")
            
        )
        )#tabItems
     )
)
