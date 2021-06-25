
# BGT Data 

library(RPostgreSQL)
library(ggplot2)
library(readxl)
library(dplyr)


# DB Connect
conn <- RPostgreSQL::dbConnect(drv = RPostgreSQL::PostgreSQL(),
                               dbname = "sdad",
                               host =  "postgis1",
                               port = 5432,
                               user = "unq6jg",
                               password = "unq6jg")

# Reading in STW SOC Codes 
setwd("/project/biocomplexity/sdad/projects_data/ncses/stw/original/wioa_2021/stw_2021")
stw <- read_xlsx("STW_2021.xlsx")

# Classifying as integer 
stw$SOC <- as.integer(stw$SOC)


# Reading in BGT Data 
bgt <- RPostgreSQL::dbGetQuery(conn = conn,
                                statement = "SELECT
                                onet,
                                soc,
                                maxdegree,
                                sector,
                                lat,
                                lon,
                                fipsstate,
                                fipscounty,
                                jobid
                                FROM bgt_job.main
                                WHERE jobdate >= '2019-01-01' AND jobid is not null
                               ")
                              
bgt_cert <- RPostgreSQL::dbGetQuery(conn = conn, 
                               statement = "SELECT * 
                               FROM bgt_job.cert 
                               LIMIT 30")

# Transforming variable soc into integer 
bgt$soc <- as.integer(bgt$soc)


# Joining the data source bgt and stw 
merged <- bgt %>% left_join(stw, by = c("soc" = "SOC"))



merged_no_na <- merged[is.na(merged$NAME) == FALSE,]



# DB Disconnect
RPostgreSQL::dbDisconnect(conn)
