library(tidyverse)
library(rstan)
library(here)
library(glue) 
source(here('helpers.R'))
options(mc.cores=parallel::detectCores())

directory <- 'bvp_goals_covid_no_reestimation'

if(!dir.exists(here(glue('model_objects/{directory}')))) {
  dir.create(here(glue('model_objects/{directory}')))
} 
if(!dir.exists(here(glue('posteriors/{directory}')))) {
  dir.create(here(glue('posteriors/{directory}')))
} 


league_info <- read_csv(here("league_info.csv"))

### Don't Re-estimate team strength for COVID by splitting into 2 seasons

for(i in 1:nrow(league_info)) {
  league <- league_info$alias[i]
  print(league)
  df <- read_leage_csvs(league) %>% 
    filter(!is.na(home_score), !is.na(away_score))
  
  ### In the Bundesliga, the last 2 games of the seaon is a promotion/regaltion game
  ### between 3rd place in 2nd division and 3rd from last in top division. Filtering out for now
  ### It's likely this is the ccould be the case in other leagues but not worrying as much about that now
  if(league == "German Bundesliga") {
    df <-
      group_by(df, season) %>%
      mutate('game_id' = 1:n()) %>%
      filter(game_id < max(game_id) - 1) %>%
      ungroup()
  }
  
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
           'pre_covid' = as.numeric(date < covid_date))
  
  ### List of Stan Params
  stan_data <- list(
    num_clubs = length(team_ids),
    num_games = nrow(df),
    home_team_code = df$home_id,
    away_team_code = df$away_id,
    h_goals = df$home_score,
    a_goals = df$away_score,
    ind_pre = df$pre_covid
  )
  
  ### Fit Model
  model <- stan(file = here('stan/goals/bvp_goals_covid.stan'), 
                data = stan_data, 
                seed = 73097,
                chains = 3, 
                iter = 7000, 
                warmup = 2000, 
                control = list(adapt_delta = 0.95))
  
  ### Save Model and Posterior
  write_rds(model, here(paste0(glue('model_objects/{directory}/'), gsub("\\s", "_", tolower(league)), '.rds')))
  posterior <- extract(model)
  write_rds(posterior, here(paste0(glue('posteriors/{directory}/'), gsub("\\s", "_", tolower(league)), '.rds')))
}
