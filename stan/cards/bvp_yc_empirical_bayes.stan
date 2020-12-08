data {
  int<lower=1> num_clubs;                                     // number of clubs
  int<lower=1> num_games;                                     // number of games
  //int<lower=1> num_seasons;                                   // number of seasons
  //int<lower=1,upper=num_seasons> season[num_games]; 
  int<lower=1,upper=num_clubs> home_team_code[num_games];     // home club for game g
  int<lower=1,upper=num_clubs> away_team_code[num_games];     // away club for game g
  int<lower=0> h_yc[num_games];                               // yellow cards for game g
  int<lower=0> a_yc[num_games];                            // away yellow goals for game g
  int<lower=0,upper=1> ind_pre[num_games];                    // indicator if game is pre/post covid
  real obs_mu;                                                // empirical bayes mean for mu
  real mu_hf_pre;
  real mu_hf_post;
  real sd_hf_pre;
  real sd_hf_post;
}
parameters {
  vector[num_clubs] gamma; 
  
  real mu;                                      // fixed intercept
  real home_field_pre;                              // home field advantage (pre-covid)
  real home_field_post;  
  real fixed_cov;                             // covariance intercepts 
  real<lower=0> sigma_g;                        // team_strength
}
model {
  vector[num_games] lambda1;
  vector[num_games] lambda2;
  vector[num_games] lambda3;
  
  // priors
  gamma ~ normal(0, sigma_g);
  mu ~ normal(obs_mu, 5);
  fixed_cov ~ normal(0, sqrt(2));
  home_field_pre ~ normal(mu_hf_pre, sd_hf_pre);
  home_field_post ~ normal(mu_hf_post, sd_hf_post);
  sigma_g ~ inv_gamma(1,1);
  
  // likelihood
  for (g in 1:num_games) {
    lambda1[g] = exp(mu + home_field_pre * ind_pre[g] + home_field_post * (1 - ind_pre[g]) + gamma[home_team_code[g]]);
    lambda2[g] = exp(mu + gamma[away_team_code[g]]);
    lambda3[g] = exp(fixed_cov); // intercept
  }
  h_yc ~ poisson(lambda1 + lambda3);
  a_yc ~ poisson(lambda2 + lambda3);
}
generated quantities{
  real lambda3;
  lambda3 = exp(fixed_cov);
}