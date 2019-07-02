library(r2dropSmart)
token <- readRDS("~/.droptoken.rds")

dropdir = "projects/PI/PROJECT_NAME"

sync("reports", remote = file.path(dropdir, "reports"), token = token,
     blackList = c("data"),
     dry = F, share = F)

#
rdrop2::drop_upload("README.html", dropdir)
