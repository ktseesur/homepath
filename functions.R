# HomePath model (reviewed with math professor, Nov 14 2026)
#
# Between deposits the balance follows geometric Brownian motion (GBM):
#   dS = mu * S * dt + sigma * S * dW
# Exact solution over one month (dt = 1/12):
#   S_minus = S * exp((mu - sigma^2 / 2) * dt + sigma * sqrt(dt) * Z),  Z ~ Normal(0, 1)
# Then the monthly savings (alpha) are added, a jump:
#   S_plus = S_minus + alpha
# We repeat this for many simulated futures (Monte Carlo).

chance_of_goal <- function(start, monthly, years, goal, w,
                           mu, sigma, r_save = 0.01, runs = 2000,
                           tax_rate = 0.15) {
  push  <- w * mu + (1 - w) * r_save
  shake <- w * sigma
  v <- rep(start, runs)
  for (k in 1:(years * 12)) {
    z <- rnorm(runs)
    growth <- (push - shake^2 / 2) / 12 + shake * sqrt(1 / 12) * z
    v <- v * exp(growth) + monthly
  }
  put_in <- start + monthly * years * 12
  v <- v - tax_rate * pmax(v - put_in, 0)
  list(chance = mean(v >= goal), endings = quantile(v, c(0.1, 0.5, 0.9)))
}

months_to_goal <- function(start, monthly, goal, w, mu, sigma,
                           r_save = 0.01, runs = 2000, tax_rate = 0.15,
                           max_years = 15, target = 0.8, n_paths = 40) {
  push  <- w * mu + (1 - w) * r_save   # drift of the mix (index fund + savings)
  shake <- w * sigma                   # risk of the mix
  dt <- 1 / 12                         # one month, in years
  v <- rep(start, runs)                # every future starts at S0
  hit <- rep(FALSE, runs)              # has this future reached the goal yet?
  hit_month <- rep(NA_integer_, runs)  # the month each future first reaches the goal (T)
  n <- max_years * 12
  chance <- numeric(n)
  bands  <- matrix(NA, n, 3)
  paths  <- matrix(NA, n, n_paths)
  for (k in 1:n) {
    z <- rnorm(runs)                                           # Z ~ Normal(0, 1)
    growth <- (push - shake^2 / 2) * dt + shake * sqrt(dt) * z # exponent of the GBM solution
    v <- v * exp(growth)                                       # S_minus: grow for one month
    v <- v + monthly                                           # S_plus: add the savings (jump alpha)
    put_in <- start + monthly * k
    after_tax <- v - tax_rate * pmax(v - put_in, 0)            # tax on gains if sold now
    new_hit <- !hit & (after_tax >= goal)                      # futures that reach the goal this month
    hit_month[new_hit] <- k                                    # save their hitting time T
    hit <- hit | new_hit                                       # once reached, it stays reached
    chance[k]  <- mean(hit)                                    # share of futures that reached it by month k
    bands[k, ] <- quantile(after_tax, c(0.1, 0.5, 0.9))
    paths[k, ] <- after_tax[1:n_paths]
  }
  list(months = which(chance >= target)[1], chance = chance,
       bands = bands, paths = paths, hit_month = hit_month)
}

years_to_goal <- function(start, monthly, goal, w, mu, sigma,
                          r_save = 0.01, runs = 2000, tax_rate = 0.15,
                          max_years = 15, target = 0.8) {
  res <- months_to_goal(start, monthly, goal, w, mu, sigma,
                        r_save, runs, tax_rate, max_years, target)
  yearly <- res$chance[seq(12, max_years * 12, by = 12)]
  list(years = which(yearly >= target)[1], chance = round(yearly, 2))
}

mortgage_payment <- function(loan, rate = 0.0711, years = 30) {
  r <- rate / 12
  n <- years * 12
  loan * r / (1 - (1 + r)^(-n))
}