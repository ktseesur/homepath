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
  push  <- w * mu + (1 - w) * r_save
  shake <- w * sigma
  v <- rep(start, runs)
  n <- max_years * 12
  chance <- numeric(n)
  bands  <- matrix(NA, n, 3)
  paths  <- matrix(NA, n, n_paths)
  for (k in 1:n) {
    z <- rnorm(runs)
    growth <- (push - shake^2 / 2) / 12 + shake * sqrt(1 / 12) * z
    v <- v * exp(growth) + monthly
    put_in <- start + monthly * k
    after_tax <- v - tax_rate * pmax(v - put_in, 0)
    chance[k]  <- mean(after_tax >= goal)
    bands[k, ] <- quantile(after_tax, c(0.1, 0.5, 0.9))
    paths[k, ] <- after_tax[1:n_paths]
  }
  list(months = which(chance >= target)[1], chance = chance,
       bands = bands, paths = paths)
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