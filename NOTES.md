# HomePath notes

## Model numbers (from my R code, estimate_mu_sigma.R)
- Data: Robert Shiller S&P 500, real total return (column Price...10), monthly, 1950 to 2026
- mu = 0.0830 (8.3% a year, after inflation) [data]
- sigma = 0.1223 (12.2% a year) [data]
- Returns are REAL, so the savings rate must be real too (about 1%)
- Model: geometric Brownian motion. Typical growth = mu - sigma^2/2 (Ito's lemma)
- Monte Carlo: 2,000 simulated futures, checked every month for up to 15 years

## Honesty notes
- Why Shiller, not FRED SP500: FRED has only 10 years, price only, no dividends or inflation
- Limits: monthly averages smooth sigma (real risk may be ~15%), newest rows estimated, no fees, gains tax simplified to 15%, past is not the future, I chose 1950 as the start

## Robustness checks (Sat 5:44 PM) [data, my R output]
Example: $2,000 saved, $500/mo, $57,814 goal, 60% index fund
- Base (1950-2026, sigma 12.2%, 2,000 runs): 101 months
- Sigma 15%: 103 months
- 10,000 runs: 101 months
- All data from 1871: 103 months
Result: answer moves 2 months at most. Robust.

## App choices
- Slider: Savings account <-> Index fund (S&P 500) in a brokerage account
- Tip: 1 to 2 years -> savings. 5+ years -> index fund can grow more but can drop
- 401(k) is for retirement, not a down payment
- Only 2 options this weekend. Bonds = next step
- Every input has a ? help popup (click to open, click again or elsewhere to close)

## Savings and inputs
- User types take-home pay (after income tax)
- Savings box auto-fills 20% of pay (50/30/20 rule) [assumption]. Typing own amount turns the rule off
- App GIVES the month and year: first month the chance reaches 80% [choice], checks up to 15 years [choice]
- Shows the real % at that month, plus Unlucky (10%) / Typical (50%) / Lucky (90%) amounts [choice]
- Fan chart: faint lines = single futures, shaded = middle 80%, dark line = typical, dashed = goal
- Home price: $289,069 Michigan median [data, Redfin]. Later county dropdown fills Zillow price [data]
- Down payment: 20%, 10%, 3.5% FHA, 3% conventional. MI help checkbox subtracts $10,000

## Monthly payment card
- Loan = home price - down payment
- Payment = standard mortgage formula, 7.11% [data, Freddie Mac], 30 years [choice]
- Not yet included: property tax, insurance, PMI (waiting on Alyssa)

## Inflation and taxes
- Everything is in today's dollars because Shiller returns are after inflation
- Assume home prices rise with inflation [assumption]. If homes rise faster, the real wait is longer
- Tax on fund gains: 15% at sale [assumption, Alyssa checking IRS]. Real tax slightly higher (taxed on before-inflation gains). Dividend and savings interest tax not included
- Income tax: handled by using take-home pay
- Property tax: goes in the monthly cost card (home price x MI rate / 12) [data, Alyssa]

## Sources from Briana [data]
- FHA 3.5% down with 580+ credit score (HUD)
- Conventional as low as 3%; 20% avoids PMI (Fannie Mae)
- MI 10K DPA: up to $10,000 (MSHDA)
- Mortgage rate 7.11%, 30-yr fixed (Freddie Mac, Nov 12 2026, freddiemac.com/pmms)
- MI median income $72,875 (Census ACS), median home $289,069 (Redfin)

## Waiting on Alyssa
- Zillow county home values CSV, MI property tax rate, MI home insurance, PMI rate, FHA MIP, IRS capital gains limits

## Number labels
- 2,000 runs = [choice] (10,000 gives the same answer)
- 1% real savings rate = [assumption]
- 10/50/90 quantiles = [choice]
- 80% chance target = [choice]
- 15% gains tax = [assumption]

## Not this weekend (pitch slide "What's next")
- Michigan map (stretch goal if time), AI helper (PathBear), HMDA regression, community/networking, home value score

## Footer line
An estimate, not a promise. Not financial advice. Market data: Robert Shiller S&P 500, 1950-2026.

## Run the app
shiny::runApp("~/HomePath", launch.browser = TRUE)

## Pitch gold (say these)
- "HomePath gives you a realistic range built on real data, and it tells you exactly what it assumes."
- "Every number is labeled data, assumption, or choice. Most apps hide their assumptions."
- "We show you when you can buy, not just a guess."
- "It turns a financial literacy class into real odds."
- "Save more, start earlier, and don't put money you need soon into stocks."
- "I kept two options to show the core risk vs return trade-off clearly. Bonds are my next step."
- "Why Shiller, not FRED: FRED has only 10 years and no dividends or inflation. Shiller goes back to 1871 with both."
- "Stocks follow geometric Brownian motion. By Ito's lemma, risk lowers typical growth by sigma^2/2. So we don't just show the average: we simulate 2,000 futures and show unlucky, typical and lucky."
- "We stress-tested it. More risk, 5x more simulations, or 150 years of data instead of 75 move the answer by 2 months at most."
- "Every term has a ? because our users are first-time buyers. HomePath teaches while you plan."
- "For short goals, saving more matters more than investing. For long goals, the index fund helps."
- If asked why Unlucky is below the goal: "You have an 82% chance, not 100%. In an unlucky market you'd be close, just a few months later."