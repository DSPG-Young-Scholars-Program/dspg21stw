
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

setwd("/project/biocomplexity/sdad/projects_data/ncses/stw/original/wioa_2021/stw_2021")
stw <- read_xlsx("STW_2021.xlsx")
stw$SOC <- as.integer(stw$SOC)

View(stw)

tbl <- RPostgreSQL::dbGetQuery(conn = conn, 
                               statement = "SELECT *
                               FROM bgt_job.main
                               WHERE jobdate >= '2019-01-01' AND jobid is not null")

tbl1 <- RPostgreSQL::dbGetQuery(conn = conn,
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
                                LIMIT 1000")
                              

View(tbl1)
summary(tbl)
summary(tbl$minsalary)

tbl1$soc <- as.integer(tbl1$soc)



d <- tbl1 %>% left_join(stw, by = c("soc" = "SOC"))

View(d)

d2 <- d[is.na(d$NAME) == FALSE,]

View(d2)

# DB Disconnect
RPostgreSQL::dbDisconnect(conn)
