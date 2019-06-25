
init <- function(path, ...) {

    # get inputs
    options <- list(...)
    project <- basename(path)
    # ensure path exists
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
    git2r::init(path)

    # create data
    dir.create(file.path(path, "data"), recursive = TRUE, showWarnings = FALSE)
    dir.create(file.path(path, "input"), recursive = TRUE, showWarnings = FALSE)
    # create code
    dir.create(file.path(path, "code"), recursive = TRUE, showWarnings = FALSE)
    dir.create(file.path(path, "run"), recursive = TRUE, showWarnings = FALSE)

    # create report
    dir.create(file.path(path, "reports"), recursive = TRUE, showWarnings = FALSE)
    dir.create(file.path(path, "reports", "results"), recursive = TRUE, showWarnings = FALSE)
    # create rmarkdown
    dir.create(file.path(path, "rmarkdown"), recursive = TRUE, showWarnings = FALSE)

    fns = list.files(file.path(system.file(package = "Bioproject", "rstudio"),
                         "templates",
                         "common"), all.files = T,
                     full.names = T)
    .void <- lapply(fns, function(fn){
        file.copy(fn, file.path(path, basename(fn)))
    })

    # load rdrop credentials
    # create dir drop2r

    # load README, replace keywords, save
    readme <- readLines(file.path(path, "README.md"))
    readme <- gsub("PROJECT_NAME", project, readme, ignore.case = TRUE)
    readme <- gsub("DROPBOX_PATH", file.path(options$dropbox_path, project),
                   readme, ignore.case = TRUE)
    writeLines(readme, file.path(path, "README.md"))

    git2r::remote_add(path, "origin", url = file.path(options$github, project))
    git2r::add(path, "README.md")
    git2r::add(path, ".gitignore")
    git2r::add(path, "render.R")
    git2r::add(path, "code/*")
    git2r::commit(path, paste("init bioproject: ", project))
}
