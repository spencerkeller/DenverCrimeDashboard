# Denver Open Crime Data Dashboard #
# 
# Shiny app started by Spencer Keller #
# 
#
#
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

suppressPackageStartupMessages(require(shiny))
suppressPackageStartupMessages(require(shinydashboard))
suppressPackageStartupMessages(require(anytime))
suppressPackageStartupMessages(require(tmap))
suppressPackageStartupMessages(require(dplyr))
suppressPackageStartupMessages(require(tidycensus))
suppressPackageStartupMessages(require(sf))


#Load data
cnty <- readRDS("./data/cnty.Rds")
nbo <- readRDS("./data/nbo.Rds")
pol_dis <- readRDS("./data/dis.Rds")
pol_pre <- readRDS("./data/pre.Rds")
pol_sta <- readRDS("./data/sta.Rds")
streets <- readRDS("./data/streets.Rds")
lrt_sta <- readRDS("./data/lrt_sta.Rds")
lrt_lin <- readRDS("./data/lrt_lin.Rds")
bus_rt <- readRDS("./data/bus_rt.Rds")
bus_stp <- readRDS("./data/bus_stp.Rds")

#Check if crime data is current, download if newer data available
last_update <- function(url) httr::HEAD(url)$headers$`last-modified` #Define function to pull 'last modified' date from header
csv_currentDate <- anytime(last_update("https://www.denvergov.org/media/gis/DataCatalog/crime/csv/crime.csv"), asUTC = T)
csv_storedDate <- anytime(file.info("./data/crime.csv")$ctime, asUTC = T)

if (csv_currentDate > csv_storedDate){
  download.file("https://www.denvergov.org/media/gis/DataCatalog/crime/csv/crime.csv", "./data/crime.csv") #Download CSV
  crime <- read.csv("./data/crime.csv") #Read CSV
  crime <- crime[!is.na(crime$GEO_LON),] #Remove rows without location information
  saveRDS(crime, file = "./data/crime.Rds") #Convert to RDS
  crime <- readRDS("./data/crime.Rds")
}

# BASIC
ui <- dashboardPage(
  dashboardHeader(title = "Test Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
               fluidRow(
                 box(plotOutput("plot1", height = 250)),
                 
                 box(
                   title = "Controls",
                   sliderInput("slider", "Number of observations:", 1, 100, 50)
                 )
               )
      ),
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
              )
    )
  )
)

server <- function(input,output){
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}

shinyApp(ui, server)