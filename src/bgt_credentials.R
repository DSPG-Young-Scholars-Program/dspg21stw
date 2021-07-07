
# Libraries 
library(stringr)
library(readxl)

# Reading in credential data 
write.table(name_count, file = "bgt_credentials.txt", sep = ",")
bgt_credentials <- read.delim("bgt_credentials.txt", sep =",", stringsAsFactors = FALSE)
ONET_credentials <- read_excel("~/dspg21STW/src/ONET_SOC_credentials.xlsx")

bgt_credentials <- toString(bgt_credentials$Var1)

View(bgt_credentials)

count <- table(bgt_credentials$Var1, ONET_credentials$Certification.Name)

View(count)

