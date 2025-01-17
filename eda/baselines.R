library(tidyverse)
library(here)
library(ggridges)
source(here('helpers.R'))

directory <- c("bvp_goals_no_corr", "bvp_yc_covid_small")[1]

league_info <- read_csv(here('league_info.csv'))
draws <- 
  map_dfr(league_info$alias, ~{
    league_ <- gsub("\\s", "_", tolower(.x))
    posterior <- read_rds(here(glue('posteriors/{directory}/{league_}.rds')))
    n_draw <-  length(posterior$home_field_pre)
    tibble('league' = .x,
           'posterior_draw' = c(posterior$home_field_pre, posterior$home_field_post),
           'hfa_type' = rep(c('Pre-COVID (w/ Fans)', 'Post-COVID (w/out Fans)'), each = n_draw))
  }) 


df_medians <- 
  group_by(draws, league, hfa_type) %>% 
  summarise('median' = median(posterior_draw))

draws$league_f <- factor(draws$league, 
  levels = df_medians$league[df_medians$hfa_type == 'Pre-COVID (w/ Fans)'][order(df_medians$median[df_medians$hfa_type == 'Pre-COVID (w/ Fans)'], decreasing = F)])



ggplot(draws, aes(x = posterior_draw, y = league_f)) +
  geom_vline(lty = 2, xintercept = 0) +
  geom_density_ridges(aes(fill = hfa_type), alpha = 0.5, quantiles = 0.5, quantile_lines = T) +
  labs(x = 'Home Advantage Coefficient (Log Scale)',
       y = 'League',
       fill = '',
       title = 'Home Advantage for Selected European Leagues',
       subtitle = 'Bivariate Poisson Model: Yellow Cards') 
ggsave(here('paper_figures/figures/yc_ridge.png'), width = 16/1.2, height = 9/1.2)


df_means <- 
  group_by(draws, league) %>% 
  summarise('mean_pre' = mean(posterior_draw[hfa_type == 'Pre-COVID (w/ Fans)']),
            'mean_post'  = mean(posterior_draw[hfa_type == 'Post-COVID (w/out Fans)'])) %>% 
  inner_join(select(league_info, 'league' = alias, logo_url))

ggplot(df_means, aes(x = mean_pre, y = mean_post)) +
  geom_abline(slope = 1, intercept = 0) +
  # scale_x_continuous(limits = c(0.01, 0.5)) +
  # scale_y_continuous(limits = c(-0.25, 0.5)) +
  geom_hline(yintercept = 0, alpha = 0.4, lty = 2) +
  # geom_label(aes(label = league)) +
  ggrepel::geom_label_repel(aes(label = league, fill = mean_post - mean_pre), size = 2.2, alpha = 0.6) +
  scale_fill_viridis_c(option = 'C') +
  labs(x = 'HA Posterior Mean Pre-COVID (Log Scale)',
       y = 'HA Posterior Mean Post-COVID (Log Scale)',
       fill = 'Change in Posterior Mean',
       title = 'Change in Home Advantage for Select European Leagues',
       subtitle = 'Bivariate Poisson Model: Yellow Cards') +
  theme(legend.text = element_text(size = 7)) 
ggsave(here('paper_figures/figures/yc_posterior_means.png'), width = 16/1.2, height = 9/1.2)
  
probs <- 
  map_dfr(league_info$alias, ~{
    league_ <- gsub("\\s", "_", tolower(.x))
    posterior <- read_rds(here(glue('posteriors/{directory}/{league_}.rds')))
    tibble('league' = .x,
           'p_decrease' = mean(posterior$home_field_pre < posterior$home_field_post))
  }) 


ggplot(probs, aes(x = p_decrease, y = fct_reorder(league, p_decrease))) +
  geom_col(fill = 'seagreen') + 
  labs(x = 'P(HA Post-COVID < HA Pre-COVID)',
       y = 'League',
       title = 'Probability of Decline in Home Advantage: Yellow Cards') +
  geom_text(aes(label = paste0(sprintf('%0.1f', 100*p_decrease), '%')), nudge_x = 0.035) +
  scale_x_continuous(labels = scales::percent)
ggsave(here('paper_figures/figures/p_hfa_decline_yc.png'), width = 16/1.2, height = 9/1.2)
    