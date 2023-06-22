
# TODO: mv ~/.Rprofile . # to store .Rprofile inside github repo
# WARNING: save to /home/vscode/.Rprofile 
#   but it will NOT be save by git to the github repo?

# https://stackoverflow.com/questions/16734937/saving-and-loading-hi>
# if (interactive()) {
#   .Last <- function() try(savehistory("~/.Rhistory"))
# }
# https://github.com/randy3k/radian/issues/98
# if (interactive()) {
#   invisible(
#     reg.finalizer(
#       .GlobalEnv,
#       eval(bquote(function(e) 
#         try(savehistory(file.path(.(getwd()), ".Rhistory"))))),
#         onexit = TRUE))
# }
# either ~/.radian_history or any local .radian_hisotry. 
# Also depends on how you start radian. 
#   For example, radian --global-history will also use the history 
#     in the home directory.



# - If you are in a container environment, please consider adding the
#  following to your configuration to silence this warning
#   options(bspm.sudo = TRUE)
# WARNING: put options into ./.Rprofile else they wont persist between R sessions
#cmdstanr::set_cmdstan_path('/home/rstudio/.cmdstan/cmdstan-2.31.0')
# options()$auto_write ; options()$mc.cores ; options()$bspm.sudo
# options(bspm.sudo = NULL, mc.cores = NULL, auto_write = NULL)

options(
# https://community.rstudio.com/t/not-able-to-install-brms-rstan-package-on-linux-r-server/96249/2
  #brms.backend = "cmdstanr", 
  # bspm: Bridge to System Package Manager
  # https://cran.r-project.org/web/packages/bspm/bspm.pdf
  # if you want to fall back to sudo in a non-interactive session, 
  # you need to set options(bspm.sudo=TRUE).
  bspm.sudo = TRUE, # options()$bspm.sudo
  # For execution on a _local_, multicore CPU with excess RAM we recommend calling
  mc.cores = parallel::detectCores(), 
  # or rstan_options(auto_write = TRUE) ?
  auto_write = FALSE # TRUE ?
) 

eval({
  r = getOption("repos") 
  r["CRAN"] = "http://cran.us.r-project.org" 
  options(repos = r)
})
## options(repos = c(c("CRAN" = "http://cran.us.r-project.org"), getOption("repos"))
