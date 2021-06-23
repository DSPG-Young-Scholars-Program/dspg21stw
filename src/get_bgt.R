
# BGT Data 

library(RPostgreSQL)
# DB Connect
conn <- RPostgreSQL::dbConnect(drv = RPostgreSQL::PostgreSQL(),
                               dbname = "sdad",
                               host =  "postgis1",
                               port = 5432,
                               user = "unq6jg",
                               password = "unq6jg")

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

# DB Disconnect
RPostgreSQL::dbDisconnect(conn)