library(rmarkdown)
setwd(here::here())

render("README.md", output_file = "README.html")

# library(rmdCore)
# run_template("pilm-bioinformatics/templates-rmd-de", "rmarkdown")
#
# run_template("rmarkdown/templates-rmd-de", NULL,
#              output_file = "reports/del/de.html",
#              options = list(
#                  se_file = "data/del_gse.rds",
#                  design = "~ treatment",
#                  alpha = 0.01,
#                  lfc = 1,
#                  contrast = "treatment.IFN_vs_None,treatment.LPS_vs_None",
#                  metadata = c("treatment", "clone")))
