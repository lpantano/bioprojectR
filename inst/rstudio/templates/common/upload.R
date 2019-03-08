library(r2dropSmart)
token <- readRDS("~/.droptoken.rds")

dropdir = "HBC Team Folder (1)/Consults/"

sync(".", remote = dropdir, token = token,
     blackList = c("_cache", "data", "Rmd$", "R$", "_files", "sh$", "Rproj$"),
     dry = T)

#
