
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

# Transforming the STW data 
stw$SOC <- gsub("-", "", stw$SOC) # removing - in soc code 
stw$SOC <- as.integer(stw$SOC) # making soc code integer 
# View(stw)


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
                                id
                                FROM bgt_job.main
                                WHERE jobdate >= '2019-01-01' AND jobdate <= '2019-12-31' AND jobid is not null AND soc is not null
                               ")

# Transforming BGT data 
bgt$soc <- gsub("-", "", bgt$soc) # removing - in soc code 
bgt$soc <- as.integer(bgt$soc) # making soc code an integer  

# Joining the data source bgt and stw 
merged <- bgt %>% left_join(stw, by = c("soc" = "SOC"))
merged_no_na <- merged[is.na(merged$NAME) == FALSE,]


# Reading in certification data                              
bgt_cert <- RPostgreSQL::dbGetQuery(conn = conn,
                                    statement = "SELECT id, jobdate, certification FROM bgt_job.cert WHERE jobdate >= '2019-01-01' AND jobdate <= '2019-12-31'")



# Joining the data source bgt_main (with no na's and no non-stw jobs) and bgt cert 
merged_cert <- merged_no_na %>% left_join(bgt_cert, by = c("id" = "id")) 
bgt_stw_cred <- merged_cert[is.na(merged_cert$certification) == FALSE,] # removing jobs with no certification 


ggplot(midwest, aes(x=, y=poptotal))


# DB Disconnect
RPostgreSQL::dbDisconnect(conn)
