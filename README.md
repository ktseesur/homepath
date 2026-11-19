# HomePath

**When can you afford a home in Michigan?** HomePath is an R Shiny web app that estimates how many years it takes to save for a down payment, using 2,000 simulated futures based on real S&P 500 data.

Live app: [homepathmi.com](https://homepathmi.com)

Built at **Hack The Nest 2026** (Eastern Michigan University). Won **Best Use of Solana (MLH)** among 101 projects.

## How the model works
- Savings grow between monthly deposits following **geometric Brownian motion**.
- Drift (μ) and volatility (σ) are estimated from **Shiller S&P 500 real returns** (`estimate_mu_sigma.R`).
- **2,000 Monte Carlo runs** find the *first hitting time*: when savings first reach the down payment goal, at a confidence level the user chooses.

## Data
Freddie Mac (mortgage rates), Tax Foundation (property taxes), HUD, and Shiller S&P 500 data.

## Files
- `app.R`: the Shiny app (interface and server)
- `functions.R`: simulation and helper functions
- `estimate_mu_sigma.R`: estimates drift and volatility
- `www/`: front-end files, including the read-only Solana balance lookup

## Run it locally
1. Install R and the packages loaded at the top of `app.R`.
2. In R: `shiny::runApp()`

## Credits
Code and model by Khongorzul Tseesuren.

Hack The Nest teammates: Alyssa Dmello (finance assumptions and research), Yunha Lee (design and branding), and Brianna Biggs (presentation).

Model guidance from Professor Ovidiu Calin (EMU Mathematics).
