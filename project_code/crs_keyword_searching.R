#danjwalton 2019

required.packages <- c("reshape2", "ggplot2", "data.table")
lapply(required.packages, require, character.only = T)

wd <- "G:/My Drive/Work/GitHub/crs_keyword_searching/"
setwd(wd)

load("project-data/crs 2012-2013.RData")
load("project-data/crs 2014-2015.RData")
load("project-data/crs 2016-2017.RData")

crs <- rbind(crs.2012.2013, crs.2014.2015, crs.2016.2017)
rm(list=c("crs.2012.2013", "crs.2014.2015", "crs.2016.2017"))

keep <- c(
  "crs_id"
  ,
  "project_number"
  ,
  "year"
  ,
  "aid_type"
  ,
  "flow_name"
  ,
  "donor_name"
  ,
  "recipient_name"
  ,
  "usd_commitment_deflated"
  ,
  "usd_disbursement_deflated"
  ,
  "purpose_name"
  ,
  "project_title"
  ,
  "short_description"
  ,
  "long_description"
  ,
  "gender"
)

crs <- crs[, ..keep]
crs <- crs[
  flow_name == "ODA Loans" 
  |
    flow_name == "ODA Grants"
  | 
    flow_name == "Equity Investment"
  | 
    flow_name == "Private Development Finance"
  ]

major.keywords <- c(
  #"keyword1"
  #,
  #"keyword2"
)

minor.keywords <- c(
  #"keyword3"
  #,
  #"keyword4"
)

disqualifying.keywords <- c(
  #"keyword5"
  #,
  #"keyword6"
  )

disqualifying.sectors <- c(
  #"sector1"
  #,
  #"sector2"
)

crs$relevance <- "None"
crs[grepl(paste(minor.keywords, collapse = "|"), tolower(paste(crs$project_title, crs$short_description, crs$long_description)))]$relevance <- "Minor"
crs[grepl(paste(major.keywords, collapse = "|"), tolower(crs$long_description))]$relevance <- "Minor"
crs[grepl(paste(major.keywords, collapse = "|"), tolower(paste(crs$short_description, crs$project_title)))]$relevance <- "Major"

crs$check <- "No"
crs[relevance == "Minor"]$check <- "potential false positive"
crs[relevance != "None"][purpose_name %in% disqualifying.sectors]$check <- "potential false negative"
crs[relevance != "None"][grepl(paste(disqualifying.keywords, collapse = "|"), tolower(paste(crs[relevance != "None"]$project_title, crs[relevance != "None"]$short_description, crs[relevance != "None"]$long_description)))]$check <- "potential false negative"

crs[relevance != "None"][grepl(paste(disqualifying.keywords, collapse = "|"), tolower(paste(crs[relevance != "None"]$project_title, crs[relevance != "None"]$short_description, crs[relevance != "None"]$long_description)))]$relevance <- "None"
crs[relevance != "None"][purpose_name %in% disqualifying.sectors]$relevance <- "None"

crs$gender <- as.character(crs$gender)
crs[is.na(gender)]$gender <- "0"
crs[gender != "1" & gender != "2"]$gender <- "No gender component"
crs[gender == "1"]$gender <- "Partial gender component"
crs[gender == "2"]$gender <- "Major gender component"

save(crs, file="output/crs.RData", compression_level = 9)

crs.years <- dcast.data.table(crs, year ~ relevance, value.var = "usd_disbursement_deflated", fun.aggregate = function (x) sum(x, na.rm=T))
crs.donors <- dcast.data.table(crs, year + donor_name ~ relevance, value.var = "usd_disbursement_deflated", fun.aggregate = function (x) sum(x, na.rm=T))
crs.recipients <- dcast.data.table(crs, year + recipient_name ~ relevance, value.var = "usd_disbursement_deflated", fun.aggregate = function (x) sum(x, na.rm=T))
crs.sectors <- dcast.data.table(crs, year + purpose_name ~ relevance, value.var = "usd_disbursement_deflated", fun.aggregate = function (x) sum(x, na.rm=T))
crs.flows <- dcast.data.table(crs, year + flow_name ~ relevance, value.var = "usd_disbursement_deflated", fun.aggregate = function (x) sum(x, na.rm=T))

fwrite(crs.years, "output/crs years.csv")
fwrite(crs.sectors, "output/crs sectors.csv")
fwrite(crs.flows, "output/crs flows.csv")
fwrite(crs.donors, "output/crs donors.csv")
fwrite(crs.recipients, "output/crs recipients.csv")

tocheck.positive <- crs[check == "potential false positive"]
tocheck.negative <- crs[check == "potential false negative"]
fwrite(tocheck.positive, "output/crs check positives.csv")
fwrite(tocheck.negative, "output/crs check negatives.csv")