library(tidyverse)
library(cmdstanr)
# library(rstan)
library(here)
library(glue) 
source(here('helpers.R'))
options(mc.cores=parallel::detectCores())

directory <- 'bvp_goals_lambda3_small'


if(!dir.exists(here(glue('model_objects/{directory}')))) {
  dir.create(here(glue('model_objects/{directory}')))
} 
if(!dir.exists(here(glue('posteriors/{directory}')))) {
  dir.create(here(glue('posteriors/{directory}')))
} 


league_info <- read_csv(here("league_info.csv"), show_col_types = FALSE)
empirical_baselines <- read_csv(here('models/empirical_baselines_small.csv'), show_col_types = FALSE)

### Iterate Over Leagues
for(i in 1:nrow(league_info)[1]) {
  league <- league_info$alias[i]
  print(league)
  
  ### Read in League Data
  df <- read_leage_csvs(league) %>% 
    filter(!is.na(home_score), !is.na(away_score))
  
  ### Filter Out Games for relegation playoffs
  keep <- 
    df %>% 
    select(home, away, season) %>% 
    pivot_longer(c('home', 'away'),
                 values_to = 'team') %>% 
    group_by(team, season) %>% 
    count() %>% 
    ungroup() %>% 
    filter(n > 3) 
  
  df <- 
    df %>% 
    semi_join(keep, by = c('home' = 'team', 'season' = 'season')) %>% 
    semi_join(keep, by = c('away' = 'team', 'season' = 'season'))
  
  ### Team IDs
  covid_date <- as.Date(league_info$restart_date[i], '%m/%d/%y')
  df <- 
    df %>% 
    mutate('season' = as.character(season)) %>% 
    mutate('home' = paste(home, season, sep = '_'),
           'away' = paste(away, season, sep = '_')) 
  team_ids <- team_codes(df)
  df <- 
    select(df, home, away, home_score, away_score, season, date) %>% 
    mutate('home_id' = team_ids[home],
           'away_id' = team_ids[away],
           'pre_covid' = as.numeric(date < covid_date),
           'season_numeric' = as.numeric(as.factor(season)))
  
  ### List of Stan Params
  stan_data <- list(
    num_clubs = length(team_ids),
    num_games = nrow(df),
    num_seasons = n_distinct(df$season_numeric),
    season = df$season_numeric,
    home_team_code = df$home_id,
    away_team_code = df$away_id,
    
    h_goals = df$home_score,
    a_goals = df$away_score,
    ind_pre = df$pre_covid,
    
    mu_hf_pre = mean(empirical_baselines$goals_ha_pre),
    mu_hf_post = mean(empirical_baselines$goals_ha_post),
    sd_hf_pre = 3 * sd(empirical_baselines$goals_ha_pre),
    sd_hf_post = 3 * sd(empirical_baselines$goals_ha_post)
  )
  
  ### Fit Model
  model <- stan(file = here(glue('stan/goals/{gsub("_small", "", directory)}.stan')), 
                data = stan_data, 
                seed = 73097,
                chains = 3, 
                iter = 20000, 
                warmup = 10000, 
                control = list(adapt_delta = 0.95),
                
                ### Don't return lambda1/lambda2 for each game x iteration to save space
                pars = c('lambda1', 'lambda2'),
                include = F)
  
  ### Save Model and Posterior
  write_rds(model, here(paste0(glue('model_objects/{directory}/'), gsub("\\s", "_", tolower(league)), '.rds')))
  posterior <- extract(model)
  write_rds(posterior, here(paste0(glue('posteriors/{directory}/'), gsub("\\s", "_", tolower(league)), '.rds')))
}
