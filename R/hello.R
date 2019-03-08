
init <- function(path, ...) {

    # ensure path exists
    dir.create(path, recursive = TRUE, showWarnings = FALSE)

    # create data
    dir.create(file.path(path, "data"), recursive = TRUE, showWarnings = FALSE)
    # create code
    dir.create(file.path(path, "code"), recursive = TRUE, showWarnings = FALSE)
    # create report
    dir.create(file.path(path, "report"), recursive = TRUE, showWarnings = FALSE)
    dir.create(file.path(path, "reports", "results"), recursive = TRUE, showWarnings = FALSE)
    fns = list.files(file.path(system.file(package = "Bioproject", "rstudio"),
                         "templates",
                         "common"), all.files = T,
                     full.names = T)
    .void <- lapply(fns, function(fn){
        file.copy(fn, file.path(path, basename(fn)))
    })

}
