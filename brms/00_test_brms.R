# Sat pt 2 26 Nov worked but needed 
#   options(brms.backend = "cmdstanr")
#   set_cmdstan_path('/home/rstudio/.cmdstan/cmdstan-2.31.0')
#   and maybe bspm.sudo = TRUE cos of Error in sink(type = "output") : invalid connection
library(cmdstanr) ; str(Sys.info()) ; check_cmdstan_toolchain() 
 cmdstan_path() ; cmdstan_version() ; 
TODO: add to container environment config ?? options(bspm.sudo = TRUE)
# options()$brms.backend ; options()$auto_write ; options()$mc.cores ; options()$bspm.sudo
library(brms) ; fit1 <- brm(count ~ zAge + zBase * Trt + (1|patient), data = epilepsy, family = poisson())
library(cmdstanr) ; (file <- file.path(cmdstan_path(), "examples", "bernoulli", "bernoulli.stan")) ; mod <- cmdstan_model(file) ; mod$print() ; mod$exe_file()
data_list <- list(N = 10, y = c(0,1,0,0,0,0,0,0,0,1)) ; 
fit <- mod$sample(data = data_list, seed = 123, chains = 4, parallel_chains = 4, refresh = 500 ) # print update every 500 iters
# mod$sample() ; 
fit$summary() ; fit$summary(variables = c("theta", "lp__"), "mean", "sd")
fit$summary("theta", pr_lt_half = ~ mean(. <= 0.5))
fit$cmdstan_summary()
draws_arr <- fit$draws(format="array") ; str(draws_arr)
draws_df <- fit$draws(format = "df") ; str(draws_df) ; print(draws_df)
draws_df_2 <- as_draws_df(draws_arr) ; identical(draws_df, draws_df_2)
library(bayesplot) ; bayesplot::mcmc_hist(fit$draws("theta"))
str(fit$sampler_diagnostics()) ; str(fit$sampler_diagnostics(format = "df")) ; fit$diagnostic_summary()
fit_with_warning <- cmdstanr_example("schools") ; ( diagnostics <- fit_with_warning$diagnostic_summary() )
fit_mle <- mod$optimize(data = data_list, seed = 123) ; fit_mle$summary() ; fit_mle$mle("theta") 
mcmc_hist(fit$draws("theta"), binwidth = 5) + vline_at(fit_mle$mle("theta"), size = 1.5)
fit_vb <- mod$variational(data = data_list, seed = 123, output_samples = 4000)
mcmc_hist(fit$draws("theta"), binwidth = 0.025) ; mcmc_hist(fit_vb$draws("theta"), binwidth = 0.025)
# fit$save_object(file = "fit.RDS") ; fit2 <- readRDS("fit.RDS")
