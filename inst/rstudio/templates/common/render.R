library(rmarkdown)
setwd(here::here())
render("code/analysis.Rmd", output_dir = "reports")
