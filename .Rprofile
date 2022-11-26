
# TODO: mv ~/.Rprofile . # to store .Rprofile inside github repo

# https://stackoverflow.com/questions/16734937/saving-and-loading-hi>
# if (interactive()) {
#   .Last <- function() try(savehistory("~/.Rhistory"))
# }
if (interactive()) {
  invisible(
    reg.finalizer(
      .GlobalEnv,
      eval(bquote(function(e) try(savehistory(file.path(.(getwd()), >
      onexit = TRUE))
}

# WARNING: save to /home/vscode/.Rprofile 
#   but it will NOT be save by git to the github repo?

# options(
# https://community.rstudio.com/t/not-able-to-install-brms-rstan-package-on-linux-r-server/96249/2
#   brms.backend = "cmdstanr", 
#   bspm.sudo = FALSE, 
#      mc.cores = parallel::detectCores(), 
#      auto_write = FALSE)
# options()$auto_write ; options()$mc.cores ; options()$bspm.sudo
# options(bspm.sudo = NULL, mc.cores = NULL, auto_write = NULL)
# on.exit(savehistory())

## options(repos = c("CRAN" = "http://cran.us.r-project.org"))
# r = getOption("repos")
# r["CRAN"] = "http://cran.us.r-project.org"
# options(repos = r)
