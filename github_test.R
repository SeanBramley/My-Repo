rm(list=ls(all=TRUE))
library("readxl")
library(stringr)
library(tidyverse)
library(plyr)

setwd("~/Documents/HealthClaims/Data")
risk_2020 <- read_excel("Riskx 2020.xlsx")
risk_2019 <- read_excel("Riskx 2019.xlsx")
risk_2018 <- read_excel("Riskx 2018.xlsx")
medical_2020 <- read_excel("Medical 2020.xlsx")
medical_2019 <- read_excel("Medical 2019.xlsx")
medical_2018 <- read_excel("Medical 2018.xlsx")
rx_2020 <- read_excel("Rx 2020.xlsx")
bio_2020 <- read_excel("Biometricsx 2020.xlsx")
hris <- read_excel("HRIS.xlsx")
hospital_2020 <- read_excel("hospital 2020.xlsx")
hospital_2019 <- read_excel("hospital 2019.xlsx")
hospital_2018 <- read_excel("hospital 2018.xlsx")
coaching <- read_excel("coaching.xlsx")


#### filtering by POS
med_mri <- medical_2020 %>% filter(CPT4==73218|	CPT4==73720|	CPT4==77021|	CPT4==72149|	CPT4==72148|	CPT4==72158|	CPT4==77084|	CPT4==70542|	CPT4==70543|	CPT4==70540|	CPT4==72196|	CPT4==72197|	CPT4==72195|	CPT4==76377|	CPT4==72197|	CPT4==72147|	CPT4==72146|	CPT4==72157|	CPT4==70336|	CPT4==74182|	CPT4==74181|	CPT4==74183|	CPT4==74185|	CPT4==71555|	CPT4==70544|	CPT4==73725|	CPT4==70549|	CPT4==70547|	CPT4==70548|	CPT4==72198|	CPT4==73225|	CPT4==70553|	CPT4==70552|	CPT4==70551|	CPT4==77047|	CPT4==77047|	CPT4==77049|	CPT4==77048|	CPT4==72142|	CPT4==72141|	CPT4==72156|	CPT4==75561|	CPT4==75557|	CPT4==71552|	CPT4==71551|	CPT4==71550|	CPT4==73721|	CPT4==73223|	CPT4==73723|	CPT4==73722|	CPT4==73221|	CPT4==73719|	CPT4==73718|	CPT4==73219|	CPT4==73220)
table(med_mri$Provider)
med_mri$POS[med_mri$POS==22] <- "Outpatient Hospital"
med_mri$POS[med_mri$POS==21] <- "Inpatient Hospital"
med_mri$POS[med_mri$POS==23] <- "Emergency Room"
med_mri$POS[med_mri$POS==11] <- "Office"


aggregate(cost~POS+CPT4, med_mri,mean)

pos_cost2020 <- sqldf::sqldf("SELECT POS, COUNT(CPT4) AS mri_count, SUM(cost) AS total_cost, SUM(cost)/COUNT(CPT4) AS cost_per_service
                         FROM med_mri
                         GROUP BY POS;")
pos_cost2020 

med2019_mri <- medical_2019 %>% 
  filter(CPT4==73218|	CPT4==73720|	CPT4==77021|	CPT4==72149|	CPT4==72148|	
           CPT4==72158|	CPT4==77084|	CPT4==70542|	CPT4==70543|	CPT4==70540|	CPT4==72196|	
           CPT4==72197|	CPT4==72195|	CPT4==76377|	CPT4==72197|	CPT4==72147|	CPT4==72146|	
           CPT4==72157|	CPT4==70336|	CPT4==74182|	CPT4==74181|	CPT4==74183|	CPT4==74185|	
           CPT4==71555|	CPT4==70544|	CPT4==73725|	CPT4==70549|	CPT4==70547|	CPT4==70548|	
           CPT4==72198|	CPT4==73225|	CPT4==70553|	CPT4==70552|	CPT4==70551|	CPT4==77047|	
           CPT4==77047|	CPT4==77049|	CPT4==77048|	CPT4==72142|	CPT4==72141|	CPT4==72156|	
           CPT4==75561|	CPT4==75557|	CPT4==71552|	CPT4==71551|	CPT4==71550|	CPT4==73721|	
           CPT4==73223|	CPT4==73723|	CPT4==73722|	CPT4==73221|	CPT4==73719|	CPT4==73718|	
           CPT4==73219|	CPT4==73220)
med2019_mri$POS[med2019_mri$POS==22] <- "Outpatient Hospital"
med2019_mri$POS[med2019_mri$POS==21] <- "Inpatient Hospital"
med2019_mri$POS[med2019_mri$POS==23] <- "Emergency Room"
med2019_mri$POS[med2019_mri$POS==11] <- "Office"

aggregate(cost~POS+CPT4, med2019_mri,mean)

pos_cost2019 <- sqldf::sqldf("SELECT POS, COUNT(CPT4) AS mri_count, SUM(cost) AS total_cost, SUM(cost)/COUNT(CPT4) AS cost_per_service
                         FROM med2019_mri
                         GROUP BY POS;")


med2018_mri <- medical_2018 %>% 
  filter(CPT4==73218|	CPT4==73720|	CPT4==77021|	CPT4==72149|	CPT4==72148|	
           CPT4==72158|	CPT4==77084|	CPT4==70542|	CPT4==70543|	CPT4==70540|	CPT4==72196|	
           CPT4==72197|	CPT4==72195|	CPT4==76377|	CPT4==72197|	CPT4==72147|	CPT4==72146|	
           CPT4==72157|	CPT4==70336|	CPT4==74182|	CPT4==74181|	CPT4==74183|	CPT4==74185|	
           CPT4==71555|	CPT4==70544|	CPT4==73725|	CPT4==70549|	CPT4==70547|	CPT4==70548|	
           CPT4==72198|	CPT4==73225|	CPT4==70553|	CPT4==70552|	CPT4==70551|	CPT4==77047|	
           CPT4==77047|	CPT4==77049|	CPT4==77048|	CPT4==72142|	CPT4==72141|	CPT4==72156|	
           CPT4==75561|	CPT4==75557|	CPT4==71552|	CPT4==71551|	CPT4==71550|	CPT4==73721|	
           CPT4==73223|	CPT4==73723|	CPT4==73722|	CPT4==73221|	CPT4==73719|	CPT4==73718|	
           CPT4==73219|	CPT4==73220)

##### 
#####
##### COST ######


## 2020 data
table(med_mri$tos)
# H: 108; X:139
med_mri_h <- med_mri %>% filter(tos=="H")
med_mri_h <- med_mri %>% filter(cost>0)


provider_cost2020 <- sqldf::sqldf("SELECT CPT4, COUNT(CPT4) AS mri_count, SUM(cost) AS total_cost, SUM(cost)/COUNT(CPT4) AS cost_per_service
                         FROM med_mri_h
                         GROUP BY CPT4;")

## 2019 data
med2019_mri_h <- med2019_mri %>% filter(tos=="H")
med2019_mri_h <- med2019_mri %>% filter(cost>0)


provider_cost2019 <- sqldf::sqldf("SELECT CPT4, COUNT(CPT4) AS mri_count, SUM(cost) AS total_cost, SUM(cost)/COUNT(CPT4) AS cost_per_service
                         FROM med2019_mri_h
                         GROUP BY CPT4;")

## 2018 data
med2018_mri_h <- med2018_mri %>% filter(tos=="H")
med2019_mri_h <- med2018_mri %>% filter(cost>0)

provider_cost2018 <- sqldf::sqldf("SELECT CPT4, COUNT(CPT4) AS mri_count, SUM(cost) AS total_cost, SUM(cost)/COUNT(CPT4) AS cost_per_service
                         FROM med2018_mri_h
                         GROUP BY CPT4;")

# 3 way inner join
# columns with x are 2020, columns with y are 2019, and columns without x and y are 2018
provider_all <- inner_join(provider_cost2020, provider_cost2019, by="CPT4")%>% inner_join(., provider_cost2018, by="CPT4")

# weight for 2020  
provider_all$weight2020 <- (provider_all$mri_count.x/sum(provider_all$mri_count.x))*provider_all$total_cost.x
# weight for 2019
provider_all$weight2019 <- (provider_all$mri_count.y/sum(provider_all$mri_count.y))*provider_all$total_cost.y
# weight for 2018
provider_all$weight2018 <- (provider_all$mri_count/sum(provider_all$mri_count))*provider_all$total_cost

# weighted average for 2020: 19126.01
sum(provider_all$weight2020)
# weighted average for 2019: 16631.24
sum(provider_all$weight2019)
# weighted average for 2018: 13109.65
sum(provider_all$weight2018)

### Utilization
table(hris$T2018)
table(hris$T2019)
table(hris$T2020)

#2018
232 + (87*2) + (87*2) + (111*3.2) # = 935.2

#2019
232 + (87*2) + (87*2) + (111*3.2) # = 935.2

#2020
231 + (87*2) + (87*2) + (111*3.2) # = 934.2

med2020_mri <- medical_2020 %>% 
  filter(CPT4==73218|	CPT4==73720| CPT4==77021|	CPT4==72149|	CPT4==72148|	CPT4==72158|	
           CPT4==77084|	CPT4==70542|	CPT4==70543|	CPT4==70540|	CPT4==72196|	CPT4==72197|	
           CPT4==72195|	CPT4==76377|	CPT4==72197|	CPT4==72147|	CPT4==72146|	CPT4==72157|
           CPT4==70336|	CPT4==74182|	CPT4==74181|	CPT4==74183|	CPT4==74185|	CPT4==71555|
           CPT4==70544|	CPT4==73725|	CPT4==70549|	CPT4==70547|	CPT4==70548|	CPT4==72198|
           CPT4==73225|	CPT4==70553|	CPT4==70552|	CPT4==70551|	CPT4==77047|	CPT4==77047|
           CPT4==77049|	CPT4==77048|	CPT4==72142|	CPT4==72141|	CPT4==72156|	CPT4==75561|
           CPT4==75557|	CPT4==71552|	CPT4==71551|	CPT4==71550|	CPT4==73721|	CPT4==73223|
           CPT4==73723|	CPT4==73722|	CPT4==73221|	CPT4==73719|	CPT4==73718|	CPT4==73219|
           CPT4==73220)

med2019_mri <- medical_2019 %>% 
  filter(CPT4==73218|	CPT4==73720|	CPT4==77021|	CPT4==72149|	CPT4==72148|	CPT4==72158|	
           CPT4==77084|	CPT4==70542|	CPT4==70543|	CPT4==70540|	CPT4==72196|	CPT4==72197|	
           CPT4==72195|	CPT4==76377|	CPT4==72197|	CPT4==72147|	CPT4==72146|	CPT4==72157|
           CPT4==70336|	CPT4==74182|	CPT4==74181|	CPT4==74183|	CPT4==74185|	CPT4==71555|
           CPT4==70544|	CPT4==73725|	CPT4==70549|	CPT4==70547|	CPT4==70548|	CPT4==72198|
           CPT4==73225|	CPT4==70553|	CPT4==70552|	CPT4==70551|	CPT4==77047|	CPT4==77047|
           CPT4==77049|	CPT4==77048|	CPT4==72142|	CPT4==72141|	CPT4==72156|	CPT4==75561|
           CPT4==75557|	CPT4==71552|	CPT4==71551|	CPT4==71550|	CPT4==73721|	CPT4==73223|
           CPT4==73723|	CPT4==73722|	CPT4==73221|	CPT4==73719|	CPT4==73718|	CPT4==73219|
           CPT4==73220)

med2018_mri <- medical_2018 %>% 
  filter(CPT4==73218|	CPT4==73720|	CPT4==77021|	CPT4==72149|	CPT4==72148|	CPT4==72158|	
           CPT4==77084|	CPT4==70542|	CPT4==70543|	CPT4==70540|	CPT4==72196|	CPT4==72197|	
           CPT4==72195|	CPT4==76377|	CPT4==72197|	CPT4==72147|	CPT4==72146|	CPT4==72157|
           CPT4==70336|	CPT4==74182|	CPT4==74181|	CPT4==74183|	CPT4==74185|	CPT4==71555|
           CPT4==70544|	CPT4==73725|	CPT4==70549|	CPT4==70547|	CPT4==70548|	CPT4==72198|
           CPT4==73225|	CPT4==70553|	CPT4==70552|	CPT4==70551|	CPT4==77047|	CPT4==77047|
           CPT4==77049|	CPT4==77048|	CPT4==72142|	CPT4==72141|	CPT4==72156|	CPT4==75561|
           CPT4==75557|	CPT4==71552|	CPT4==71551|	CPT4==71550|	CPT4==73721|	CPT4==73223|
           CPT4==73723|	CPT4==73722|	CPT4==73221|	CPT4==73719|	CPT4==73718|	CPT4==73219|
           CPT4==73220)

## 2020 data
mri_2020 <- sqldf("SELECT CPT4, COUNT(CPT4) AS mri_count, COUNT(CPT4)*1000/934.2 AS per_1000_enrollees
                         FROM med2020_mri
                         GROUP BY CPT4;")

## 2019 data
mri_2019 <- sqldf("SELECT CPT4, COUNT(CPT4) AS mri_count, COUNT(CPT4)*1000/935.2 AS per_1000_enrollees
                         FROM med2019_mri
                         GROUP BY CPT4;")

## 2018 data
mri_2018 <- sqldf("SELECT CPT4, COUNT(CPT4) AS mri_count, COUNT(CPT4)*1000/935.2 AS per_1000_enrollees
                         FROM med2018_mri
                         GROUP BY CPT4;")

# Grouping MRI counts Per 1000 enrollees for all 3 years
mri_all <- sqldf("SELECT a.CPT4, a.per_1000_enrollees AS count_2018, b.per_1000_enrollees AS count_2019, c.per_1000_enrollees AS count_2020
                 FROM mri_2018 AS a
                 INNER JOIN mri_2019 AS b
                 ON a.CPT4 = b.CPT4
                 INNER JOIN mri_2020 AS c
                 ON a.CPT4 = c.CPT4;")

# Combines tables for counts per 1000 enrollees and weighted costs across 3 years
cost_utilization <- sqldf("SELECT a.CPT4, a.count_2018, b.weight2018 AS cost_2018, a.count_2019, b.weight2019 AS cost_2019, a.count_2020, b.weight2020 AS cost_2020
                          FROM mri_all AS a
                          INNER JOIN provider_all AS b
                          ON a.CPT4 = b.CPT4;")




