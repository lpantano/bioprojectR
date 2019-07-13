
init <- function(path, ...) {

    # get inputs
    options <- list(...)
    project <- basename(path)
    pi <- unlist(strsplit(project, "_"))[1]
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


    # load README, replace keywords, save
    readme <- readLines(file.path(path, "README.md"))
    readme <- gsub("PI", pi, readme, ignore.case = F)
    readme <- gsub("PROJECT_NAME", project, readme, ignore.case = F)
    readme <- gsub("DROPBOX_PATH", file.path(options$dropbox_path, project),
                   readme, ignore.case = F)
    writeLines(readme, file.path(path, "README.md"))

    # load upload.R and update paths
    upload <- readLines(file.path(path, "upload.R"))
    upload <- gsub("PROJECT_NAME", project, upload, ignore.case = F)
    upload <- gsub("PI", pi, upload, ignore.case = F)
    writeLines(upload, file.path(path, "upload.R"))

    save(project, pi, options, file = file.path(path, ".configuration"))

}


#' @export
sync <- function(project=NULL,
                 dropbox = NULL,
                 github = NULL,
                 user = NULL,
                 create = TRUE,
                 labels = TRUE,
                 local = TRUE){
    if (file.exists(".configuration")){
        load(".configuration")
        user = options$github_u
        github = options$github_api
        dropbox = options$dropbox_path
    }
    # load rdrop credentials
    # create dir drop2r
    if (!is.null(dropbox)){
        stopifnot(file.exists("~/.droptoken.rds"))
        library(rdrop2)
        token <- readRDS("~/.droptoken.rds")
    }

    if (!is.null(github) & !is.null(user)){

        key_get("GITHUB_PAT")
        if (create)
            api_create_repo(github, user, project)
        if (labels){
            api_clean_labels(github, user, project)
            api_create_labels(github, user, project)
        }
        if (local){
            git2r::remote_add(".", "origin",
                              url = api_get_git(github,
                                                user,
                                                project))
            git2r::add(".", "README.md")
            git2r::add(".", ".gitignore")
            git2r::add(".", "render.R")
            git2r::add(".", "upload.R")
            git2r::add(".", "code/*")
            git2r::commit(".", paste("init bioproject: ", project))
        }

    }
}

#' @export
check_config <- function(API=NULL, USER=NULL){

    if (!is.null(API) && !is.null(USER)){
        # check github token setup
        message("Checking GitHub credentials")
        # browser()
        key_get("GITHUB_PAT")
        message("Your github token is setup with keyring. Thanks")
        res = GET(paste0(API, "/user/repos"),
                  authenticate(USER, key_get("GITHUB_PAT")))
        if (res$status_code != "200") {
            warning("Connection failed. Please make sure you have access.")
            warning("Make this works:")
            warning("GET(\"", API, "/user/repos\", authenticate(\"", USER, "\",  key_get(\"GITHUB_PAT\")))")
        }
    }else{
        message("Skipping github check. Give API (like https://github.mit.edu/api/v3/) and USER to check.")
    }


    if(!file.exists("~/.droptoken.rds")){
        warning("Skipping dropbox since token is not setup")
        message("https://github.com/karthik/rdrop2#authentication")
    }else{
        message("Checking Dropbox credentials")
        library(rdrop2)
        token <- readRDS("~/.droptoken.rds")
        if (!exists("token")){
            warning("dropbox auth token doesn't exists")
            message("set up here https://github.com/karthik/rdrop2#authentication")
        }else{
            r = rdrop2::drop_acc(dtoken = token)
            message("This is your info: ", r$name$display_name)
        }
    }

}

api_get_git <- function(API, USER, REPO){
    res = GET(paste0(API, "/repos/PILM-bioinformatics/", REPO),
            authenticate(USER, key_get("GITHUB_PAT")))
    content(res)$ssh
}


api_create_repo <- function(API, USER, REPO){
    res = POST(paste0(API, "/orgs/PILM-bioinformatics/repos"),
         body=list(name=REPO, private="true", has_issue="true"),
         encode="json",
         authenticate(USER, key_get("GITHUB_PAT"))
         )
    message(content(res)$status)
}

api_clean_labels <- function(API, USER, REPO){
    old = c("bug", "duplicate", "enhancement",
            "invalid", "question", "wontfix",
            "good%20first%20issue",
            "help%20wanted")
    res = sapply(old, function(l){
        DELETE(paste0(API, "/repos/PILM-bioinformatics/",
                      REPO, "/labels/", l),
               authenticate(USER, key_get("GITHUB_PAT"))
               )
    })
}

api_create_labels <- function(API, USER, REPO){
    new = list(list(name="project" , color="a2eeef"),
            list(name="meeting", color="e4e669"),
            list(name="question", color="d876e3"),
            list(name="todo", color="4163a8"))
    res = sapply(new, function(l){
        POST(paste0(API, "/repos/PILM-bioinformatics/",
                    REPO, "/labels"),
             body = list(name=l$name, color=l$color),
             encode="json",
             authenticate(USER, key_get("GITHUB_PAT"))
             )
    })
}
