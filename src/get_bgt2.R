
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
                               user = Sys.getenv("DB_USR"),
                               password = Sys.getenv("DB_PWD"))

# Reading in STW SOC Codes 
setwd("/project/biocomplexity/sdad/projects_data/ncses/stw/original/wioa_2021/stw_2021")
stw <- read_xlsx("STW_2021.xlsx")
stw$SOC <- gsub("-", "", stw$SOC)
# Classifying as integer 
stw$SOC <- as.integer(stw$SOC)

View(stw)


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
                                WHERE jobdate >= '2019-01-01' AND jobdate <= '2019-12-31' AND jobid is not null AND soc is not null
                               ")

                              
bgt_cert <- RPostgreSQL::dbGetQuery(conn = conn,
                                    statement = "SELECT id, jobdate, certification FROM bgt_job.cert WHERE jobdate >= '2019-01-01' AND jobdate <= '2019-12-31'")


# Transforming variable soc into integer 
bgt$soc <- gsub("-", "", bgt$soc)
bgt$soc <- as.integer(bgt$soc)



# Joining the data source bgt and stw 
merged <- bgt %>% left_join(stw, by = c("soc" = "SOC"))



merged_no_na <- merged[is.na(merged$NAME) == FALSE,]

#View(merged_no_na)
#View(stw)
# DB Disconnect
RPostgreSQL::dbDisconnect(conn)
