library(readxl)
shiller <- read_excel("data/ie_data.xls", sheet = "Data", skip = 7)
head(shiller)

library(dplyr)
s <- shiller |>
  select(Date, real_tr = Price...10) |>
  filter(!is.na(real_tr), Date >= 1950)
r <- diff(log(s$real_tr))
sigma <- sd(r) * sqrt(12)
mu <- mean(r) * 12 + sigma^2 / 2
mu
sigma
params <- list(mu = mu, sigma = sigma)
saveRDS(params, "data/mu_sigma.rds")

