
# BGT Data 
# DB Connect
conn <- RPostgreSQL::dbConnect(drv = RPostgreSQL::PostgreSQL(),
                               dbname = "sdad",
                               host =  "postgis1",
                               port = 5432,
                               user = Sys.getenv("DB_USR"),
                               password = Sys.getenv("DB_PWD"))
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
                               WHERE jobdate >= '2019-01-01' AND jobdate <= '2019-12-31' AND jobid is not null AND soc is not null")


# Reading in certification data                              
bgt_cert <- RPostgreSQL::dbGetQuery(conn = conn,
                                    statement = "SELECT id, jobdate, certification FROM bgt_job.cert WHERE jobdate >= '2019-01-01' AND jobdate <= '2019-12-31'")

# DB Disconnect
RPostgreSQL::dbDisconnect(conn)


# Libraries 
library(RPostgreSQL)
library(ggplot2)
library(readxl)
library(dplyr)


# Reading in STW SOC Codes 
stw <- read_xlsx("STW_2021.xlsx")

# Transforming the STW data 
stw$SOC <- gsub("-", "", stw$SOC) # removing - in soc code 
stw$SOC <- as.integer(stw$SOC) # making soc code integer 
# View(stw)


# Transforming BGT data 
bgt$soc <- gsub("-", "", bgt$soc) # removing - in soc code 
bgt$soc <- as.integer(bgt$soc) # making soc code an integer  

# Joining the data source bgt and stw 
merged <- bgt %>% left_join(stw, by = c("soc" = "SOC"))  # merging on soc variable 
merged_no_na <- merged[is.na(merged$NAME) == FALSE,] # removing variables with no name 


# Joining the data source bgt_main (with no na's and no non-stw jobs) and bgt cert 
merged_cert <- merged_no_na %>% left_join(bgt_cert, by = c("id" = "id")) # merging on id variable 
bgt_stw_cred <- merged_cert[is.na(merged_cert$certification) == FALSE,] # removing jobs with no certification 

View(bgt_stw_cred)
# Pulling out credential names and frequency 
name_count <- table(bgt_stw_cred$certification, bgt_stw_cred$soc)
View(name_count)


# Writing a table with just credentials 
write.table(name_count, file = "bgt_credentials.txt", sep = ",")
bgt_credentials <- read.delim("bgt_credentials.txt", sep =",")


View(bgt_credentials)


