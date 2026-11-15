library(shiny)
library(bslib)
library(ggplot2)
source("functions.R")
params <- readRDS("data/mu_sigma.rds")

# ---- design: colors from Yunha's slides and logo [choice] ----
col_forest <- "#213323"   # dark forest green (slide background)
col_olive  <- "#62683D"   # olive green (slide boxes)
col_sage   <- "#8FA35B"   # sage green (logo leaf)
col_goal   <- "#752C29"   # deep red (slide accent) for the goal line

# ---- design: custom CSS (header, cards, big numbers, sidebar, FAQ) ----
app_css <- HTML("
:root {
  --hp-forest: #213323; --hp-olive: #62683D; --hp-sage: #8FA35B; --hp-gold: #B7A171;
  --hp-red: #752C29; --hp-cream: #F4EAD5; --hp-paper: #FFFCF5; --hp-ink: #29261E;
  --hp-muted: #6B6656; --hp-line: #E7DCC3; --hp-peach: #F2C9A0;
}
body { background: var(--hp-cream); color: var(--hp-ink); }
h1, h2, h3, h4, .serif { font-family: Georgia, 'Times New Roman', serif; }

/* top bar: solid forest green with a thin gold line, like the slides */
.navbar {
  background: var(--hp-forest) !important;
  border-bottom: 3px solid var(--hp-gold) !important;
}
.navbar .navbar-brand, .navbar .bslib-page-title { color: var(--hp-cream) !important; }
.hp-brand { font-family: Georgia, 'Times New Roman', serif; font-weight: 700; font-size: 1.6rem;
  vertical-align: middle; color: #F4EAD5 !important; letter-spacing: 0.01em; }
.hp-tagline { font-family: Georgia, 'Times New Roman', serif; font-style: italic; font-weight: 400;
  font-size: 0.95rem; color: var(--hp-gold); margin-left: 0.9rem; vertical-align: middle; }

/* sidebar */
.bslib-sidebar-layout > .sidebar { background: var(--hp-paper); border-right: 1px solid var(--hp-line); }
.sidebar-title { font-family: Georgia, 'Times New Roman', serif; color: var(--hp-forest); }
.form-control, .form-select { border-radius: 10px; border-color: #DCCFB1; background-color: #FFFFFF; }
.form-control:focus, .form-select:focus {
  border-color: var(--hp-olive); box-shadow: 0 0 0 0.2rem rgba(98, 104, 61, 0.18);
}
.input-group-text { background: var(--hp-cream); border-color: #DCCFB1; color: var(--hp-muted); }
.form-check-input:checked { background-color: var(--hp-olive); border-color: var(--hp-olive); }
.irs--shiny .irs-bar, .irs--shiny .irs-single { background: var(--hp-olive); border-color: var(--hp-olive); }
.irs--shiny .irs-handle { border-color: var(--hp-olive); }

/* the ? help buttons */
.help-q {
  display: inline-flex; align-items: center; justify-content: center;
  width: 18px; height: 18px; padding: 0; font-size: 0.7rem; font-weight: 700;
  background: var(--hp-cream) !important; color: var(--hp-forest) !important;
  border: 1px solid var(--hp-line); border-radius: 50%; transition: all 0.15s ease;
}
.help-q:hover { background: var(--hp-forest) !important; color: var(--hp-cream) !important; }

/* cards: warm paper, soft shadow, round corners */
.card {
  background: var(--hp-paper); border: 1px solid var(--hp-line); border-radius: 18px; overflow: hidden;
  box-shadow: 0 1px 2px rgba(41, 38, 30, 0.05), 0 10px 28px rgba(41, 38, 30, 0.08);
}
.card-header {
  background: transparent; border-bottom: 1px solid var(--hp-line);
  font-family: Georgia, 'Times New Roman', serif; font-size: 1.2rem; font-weight: 700;
  color: var(--hp-forest); padding: 0.9rem 1.25rem;
}
.card-body { padding: 1.25rem; }

/* big headline numbers: editorial serif */
.hero-num {
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(2.2rem, 4vw, 3.2rem); font-weight: 700; letter-spacing: -0.01em;
  line-height: 1.05; margin: 0; color: var(--hp-forest); font-variant-numeric: lining-nums;
}
.eyebrow { font-size: 0.9rem; color: var(--hp-muted); margin-bottom: 0.25rem; }
.chance-pill { background: var(--hp-cream); border-radius: 14px; padding: 0.5rem 0.9rem; text-align: center; }
.chance-pill .num { font-family: Georgia, 'Times New Roman', serif; font-size: 1.7rem; font-weight: 700;
  color: var(--hp-olive); line-height: 1.1; }
.chance-pill small { color: var(--hp-muted); }
.hp-callout {
  background: var(--hp-cream); border-left: 3px solid var(--hp-gold); border-radius: 10px;
  padding: 0.6rem 0.9rem; font-size: 0.92rem; color: var(--hp-ink);
}

/* unlucky / typical / lucky tiles */
.stat-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.75rem; }
.stat { border: 1px solid var(--hp-line); border-radius: 14px; padding: 0.75rem; text-align: center; background: #FFFFFF; }
.stat-label { font-size: 0.75rem; color: var(--hp-muted); text-transform: uppercase; letter-spacing: 0.05em; }
.stat-value { font-family: Georgia, 'Times New Roman', serif; font-size: 1.4rem; font-weight: 700; }
.tone-low  { color: var(--hp-red); }
.tone-mid  { color: var(--hp-forest); }
.tone-high { color: var(--hp-olive); }

/* payment card rows */
.cost-row { border-bottom: 1px solid var(--hp-line) !important; font-size: 0.95rem; }
.cost-row:last-child { border-bottom: none !important; }
.section-label {
  font-size: 0.75rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase;
  color: var(--hp-muted); margin: 1.25rem 0 0.25rem;
}

/* Ask HomePath strip at the top and the FAQ card */
.ask-strip {
  display: flex; align-items: center; gap: 0.9rem; flex-wrap: wrap;
  background: var(--hp-forest); color: var(--hp-cream); border-radius: 18px;
  padding: 0.6rem 1rem; margin-bottom: 1rem; text-decoration: none;
  box-shadow: 0 8px 24px rgba(33, 51, 35, 0.18); transition: transform 0.15s ease, box-shadow 0.15s ease;
}
.ask-strip:hover { color: var(--hp-cream); transform: translateY(-1px); box-shadow: 0 12px 28px rgba(33, 51, 35, 0.25); }
.ask-strip .ask-title { font-family: Georgia, 'Times New Roman', serif; font-size: 1.15rem; font-weight: 700; }
.ask-strip .ask-sub { font-size: 0.85rem; color: var(--hp-gold); }
.ask-strip .ask-btn {
  margin-left: auto; background: var(--hp-cream); color: var(--hp-forest); font-weight: 700;
  border-radius: 999px; padding: 0.35rem 1rem; font-size: 0.9rem; white-space: nowrap;
}
/* mascot.png is Yunha's HOMEPath.png: the dog is the top 72% of the picture,
   so the box shows only that part and hides the word HOMEPath underneath */
.mascot-crop { display: inline-block; overflow: hidden; flex-shrink: 0; }
.mascot-crop img { display: block; }
.mascot-sm { height: 52px; width: 66px; }
.mascot-sm img { height: 72px; width: 66px; }
.ask-strip .mascot-crop { background: var(--hp-cream); border-radius: 12px; }
.mascot-md { height: 64px; width: 81px; margin-right: 0.6rem; }
.mascot-md img { height: 88px; width: 81px; }
.faq-head { display: flex; align-items: center; }
.faq-head small { display: block; font-family: Inter, system-ui, sans-serif; font-weight: 400;
  font-size: 0.85rem; color: var(--hp-muted); }
.accordion { --bs-accordion-bg: #FFFFFF; --bs-accordion-border-color: var(--hp-line);
  --bs-accordion-active-bg: var(--hp-cream); --bs-accordion-active-color: var(--hp-forest);
  --bs-accordion-btn-focus-box-shadow: 0 0 0 0.2rem rgba(98, 104, 61, 0.18); }
.accordion-button { font-weight: 600; color: var(--hp-ink); }
.faq-src { font-size: 0.8rem; color: var(--hp-muted); margin-bottom: 0; }
.faq-src a { color: var(--hp-olive); }
.hp-footer { color: var(--hp-muted); font-size: 0.8rem; text-align: center; margin-top: 0.5rem; }
")

# dog mascot: the first picture found in the www folder (png, jpg or webp), cropped to the dog
# if there is no picture, the app still runs and just shows no dog
mascot_file <- list.files("www", pattern = "\\.(png|jpe?g|webp)$", ignore.case = TRUE)[1]
mascot <- function(size) {
  if (is.na(mascot_file)) return(NULL)
  tags$span(class = paste("mascot-crop", size),
            tags$img(src = mascot_file, alt = "HomePath dog mascot",
                     onerror = "this.parentNode.style.display='none'"))
}

help_icon <- function(title, text) {
  popover(
    tags$span("?", class = "help-q badge rounded-pill bg-light text-primary",
              style = "cursor: pointer;"),
    text, title = title
  )
}

label_row <- function(label, title, help) {
  tags$div(class = "d-flex align-items-center gap-1 mb-1 fw-semibold",
           tags$span(label), help_icon(title, help))
}

money_input <- function(id, label, title, help, value) {
  tags$div(
    label_row(label, title, help),
    tags$div(class = "input-group",
             tags$span(class = "input-group-text", "$"),
             tags$input(id = id, type = "number", class = "form-control",
                        value = value, min = 0)
    )
  )
}

# one clean row: label (+ optional ?) on the left, value on the right
cost_row <- function(label, value, help = NULL) {
  tags$div(class = "cost-row d-flex justify-content-between align-items-center py-2",
           tags$span(class = "d-flex align-items-center gap-1", label,
                     if (!is.null(help)) help_icon(label, help)),
           tags$span(class = "fw-semibold", value))
}

close_help_js <- tags$script(HTML("
document.addEventListener('click', function(e) {
  document.querySelectorAll('.help-q').forEach(function(el) {
    if (!el.contains(e.target)) {
      var p = bootstrap.Popover.getInstance(el);
      if (p) p.hide();
    }
  });
});"))

dollars <- function(x) paste0("$", formatC(round(x), format = "d", big.mark = ","))

# ---- FAQ: Briana's answers (static text, no AI) ----
# one question: click to open, answer + source underneath
faq_item <- function(q, a, src, url = NULL) {
  accordion_panel(
    q,
    tags$p(a),
    tags$p(class = "faq-src", "Source: ", src,
           if (!is.null(url)) tags$span(" (", tags$a(href = url, target = "_blank",
                                                     sub("https://(www\\.)?", "", url)), ")"))
  )
}

cfpb  <- "https://www.consumerfinance.gov"
hud   <- "https://www.hud.gov"
mshda <- "https://www.michigan.gov/mshda"
invst <- "https://www.investor.gov"

faq_buying <- accordion(
  open = FALSE,
  faq_item("What is a down payment?",
           "A down payment is money paid upfront when purchasing a home. It reduces the amount borrowed through a mortgage.",
           "Consumer Financial Protection Bureau (CFPB), 2026", cfpb),
  faq_item("What is a mortgage?",
           "A mortgage is a loan used to purchase a home. The borrower repays the loan over time through scheduled monthly payments.",
           "CFPB, 2026", cfpb),
  faq_item("What is mortgage pre-approval?",
           "Pre-approval is an estimate from a lender of how much money a borrower may qualify to borrow. It can help establish a homebuying budget.",
           "CFPB, 2026", cfpb),
  faq_item("What is an FHA loan?",
           "An FHA loan is a mortgage insured by the Federal Housing Administration. It is designed to help eligible borrowers qualify for home financing.",
           "HUD, 2026", hud),
  faq_item("What is the MI 10K DPA Program?",
           "The MI 10K DPA program is a Michigan down payment assistance program offered through MSHDA for eligible homebuyers.",
           "MSHDA, 2026", mshda),
  faq_item("What costs come with a home besides the mortgage?",
           "Homeownership may include property taxes, insurance, utilities, maintenance expenses, repairs, and closing costs.",
           "CFPB, 2026", cfpb),
  faq_item("What is PMI and how do I avoid it?",
           "Private Mortgage Insurance (PMI) may be required on some conventional loans when a borrower makes a smaller down payment. Requirements vary by lender and loan program. A down payment of 20% or more typically avoids PMI.",
           "CFPB, 2026", cfpb)
)

faq_homepath <- accordion(
  open = FALSE,
  faq_item("Savings account or index fund: what's the difference?",
           "Savings accounts are generally designed for stability and easier access to funds. Index funds may experience higher growth or losses over time because their value can increase or decrease.",
           "Investor.gov, 2026", invst),
  faq_item("Why does HomePath show a range instead of one answer?",
           "Financial outcomes can vary due to market conditions, savings habits, and other factors. Showing a range helps users understand that multiple outcomes are possible.",
           "HomePath"),
  faq_item("Are HomePath projections guaranteed?",
           "No. HomePath provides educational estimates based on historical data and user inputs. Actual results may be different.",
           "HomePath"),
  faq_item("Does HomePath provide financial advice?",
           "No. HomePath is an educational and planning tool. Information provided by the platform should not be considered financial, legal, investment, or lending advice.",
           "HomePath")
)

# body font: Inter from Google Fonts; if offline, the browser uses the next font in the list
app_font  <- font_collection(font_google("Inter", local = FALSE),
                             "system-ui", "-apple-system", "Segoe UI", "Roboto", "Arial", "sans-serif")
# heading font: Georgia, the serif used in Yunha's slides (already on every computer)
head_font <- font_collection("Georgia", "Times New Roman", "serif")

ui <- page_sidebar(
  title = tags$span(tags$span(class = "hp-brand", "HomePath"),
                    tags$span(class = "hp-tagline d-none d-md-inline",
                              "Plan when you can afford your first home in Michigan")),
  window_title = "HomePath",
  fillable = FALSE,
  theme = bs_theme(
    version = 5,
    primary = col_forest, secondary = col_olive, success = col_olive, danger = col_goal,
    bg = "#F4EAD5", fg = "#29261E",
    base_font = app_font, heading_font = head_font,
    "input-bg" = "#FFFFFF", "border-radius" = "0.75rem"
  ),
  tags$head(tags$style(app_css)),
  sidebar = sidebar(
    title = "Your plan",
    width = 300,
    money_input("pay", "Monthly take-home pay", "Take-home pay",
                "The money that lands in your bank account each month, after taxes and deductions.",
                value = 2500),
    money_input("save", "My monthly savings", "50/30/20 rule",
                "A common budget tip: about 50% of pay for needs, 30% for wants, and 20% for savings.",
                value = 500),
    checkboxInput("use_rule", "Use 50/30/20 rule", value = TRUE),
    money_input("start", "Savings today", "Savings today",
                "Money you already have set aside for a home.",
                value = 2000),
    money_input("price", "Home price", "Home price",
                "Starts at the Michigan median sale price, $289,069 (Redfin). Change it to the home you want.",
                value = 289069),
    tags$div(
      label_row("Down payment", "Down payment",
                "Cash you pay upfront. 20% avoids PMI (extra insurance). FHA allows 3.5% with a 580+ credit score (HUD). Some conventional loans allow 3% (Fannie Mae)."),
      selectInput("down", NULL, width = "100%",
                  choices = c("20% (no PMI)" = 0.20, "10%" = 0.10,
                              "3.5% (FHA)" = 0.035, "3% (conventional)" = 0.03))
    ),
    tags$div(
      label_row("Mortgage rate (30-year fixed)", "Mortgage rate",
                "The yearly interest the bank charges on your loan. Fixed means it never changes. 7.11% is the 30-year fixed average (Freddie Mac, Nov 12 2026). It only changes your monthly payment, not how long you save."),
      selectInput("rate", NULL, width = "100%", selected = 0.0711,
                  choices = c("5%" = 0.05, "6%" = 0.06,
                              "7.11% (average now)" = 0.0711, "8%" = 0.08))
    ),
    tags$div(class = "d-flex align-items-center gap-1",
             checkboxInput("dpa", "Michigan down payment help", value = FALSE),
             help_icon("MI 10K DPA",
                       "Michigan's MSHDA program gives up to $10,000 toward your down payment. You must meet income and price limits and use a participating lender.")
    ),
    tags$div(
      label_row("Money in index fund", "Savings vs index fund",
                "Savings account: safe, grows slowly. Index fund (S&P 500): grows more on average but can drop. 1-2 years: savings. 5+ years: index fund can help."),
      sliderInput("w", NULL, min = 0, max = 100, value = 60, post = "%", width = "100%")
    ),
    tags$div(
      label_row("How sure do you want to be?", "How sure",
                "The future is uncertain, so we simulate 2,000 possible futures. Pick 80% and we show the month when 80% of them have reached your goal. More sure means a longer wait."),
      selectInput("sure", NULL, width = "100%", selected = 0.8,
                  choices = c("50% (coin flip)" = 0.5, "80%" = 0.8,
                              "90%" = 0.9, "95%" = 0.95))
    )
  ),
  # clickable strip at the top: jumps down to the FAQ
  tags$a(href = "#faq", class = "ask-strip",
         onclick = "document.getElementById('faq').scrollIntoView({behavior: 'smooth', block: 'start'}); return false;",
         mascot("mascot-sm"),
         tags$div(tags$div(class = "ask-title", "Questions? Ask HomePath"),
                  tags$div(class = "ask-sub", "Simple answers about down payments, loans and costs, with sources")),
         tags$span(class = "ask-btn", "See answers")),
  layout_columns(
    col_widths = c(8, 4),
    card(card_header("When can you buy?"), uiOutput("result"),
         plotOutput("fan", height = "340px")),
    card(card_header("Your monthly payment"), uiOutput("cost"))
  ),
  tags$div(id = "faq", class = "mt-3",
           card(
             card_header(tags$div(class = "faq-head",
                                  mascot("mascot-md"),
                                  tags$div("Ask HomePath",
                                           tags$small("Click a question to see the answer.")))),
             layout_columns(
               col_widths = c(6, 6),
               tags$div(tags$p(class = "section-label mt-0", "Buying a home"), faq_buying),
               tags$div(tags$p(class = "section-label mt-0", "Saving and HomePath"), faq_homepath)
             )
           )
  ),
  tags$p(class = "hp-footer",
         "An estimate, not a promise. Not financial advice. Market data: Robert Shiller S&P 500, 1950-2026."),
  close_help_js
)

server <- function(input, output, session) {
  observe({
    if (isTRUE(input$use_rule)) {
      updateNumericInput(session, "save", value = round(input$pay * 0.2))
    }
  })
  observeEvent(input$save, {
    if (isTRUE(input$use_rule) && !is.na(input$save) &&
        input$save != round(input$pay * 0.2)) {
      updateCheckboxInput(session, "use_rule", value = FALSE)
    }
  })
  
  down_amt <- reactive(input$price * as.numeric(input$down))
  goal <- reactive(max(down_amt() - if (isTRUE(input$dpa)) 10000 else 0, 0))
  
  sim <- reactive({
    req(input$save, input$start, input$price)
    set.seed(1)
    months_to_goal(input$start, input$save, goal(), input$w / 100,
                   params$mu, params$sigma, target = as.numeric(input$sure))
  })
  
  output$result <- renderUI({
    if (input$start >= goal()) {
      return(tags$div(
        tags$h1("You're ready now!", class = "hero-num"),
        tags$p(class = "mt-2", paste0("Your savings already cover the ", dollars(goal()), " you need."))
      ))
    }
    m <- sim()$months
    if (is.na(m)) {
      return(tags$div(
        tags$h2("Not within 15 years", class = "fw-bold"),
        tags$p("Try saving more, a smaller down payment, or a lower home price.")
      ))
    }
    when <- seq(Sys.Date(), by = "month", length.out = m + 1)[m + 1]
    pct  <- round(100 * sim()$chance[m])
    b    <- sim()$bands[m, ]
    # range of hitting times: when 10% and 90% of futures have reached the goal
    ch    <- sim()$chance
    month_label <- function(k) format(seq(Sys.Date(), by = "month", length.out = k + 1)[k + 1], "%B %Y")
    early <- which(ch >= 0.10)[1]
    late  <- which(ch >= 0.90)[1]
    range_txt <- paste0("Range: 80% of futures reach your goal between ", month_label(early), " and ",
                        if (is.na(late)) "more than 15 years from now" else month_label(late), ".")
    # one tile: label on top, dollar amount below
    box <- function(lbl, val, cls) tags$div(class = "stat",
                                            tags$div(class = "stat-label", lbl),
                                            tags$div(class = paste("stat-value", cls), dollars(val)))
    tags$div(
      tags$p("You can likely buy in", class = "eyebrow"),
      tags$div(class = "d-flex flex-wrap align-items-center justify-content-between gap-3",
               tags$h1(format(when, "%B %Y"), class = "hero-num"),
               tags$div(class = "chance-pill",
                        tags$div(class = "num", paste0(pct, "%")),
                        tags$small("chance by then"))
      ),
      tags$p(class = "mt-3 mb-2", paste0(m %/% 12, " yr ", m %% 12, " mo. You need ",
                                         dollars(goal()), ". ", pct, "% of 2,000 simulated futures reach your goal by then.")),
      tags$div(class = "hp-callout mb-3", range_txt),
      tags$p(class = "section-label mt-0", paste0("What you might have by ", format(when, "%B %Y"))),
      tags$div(class = "stat-row mb-2",
               box("Unlucky (10%)", b[1], "tone-low"),
               box("Typical (50%)", b[2], "tone-mid"),
               box("Lucky (90%)",   b[3], "tone-high"))
    )
  })
  
  output$fan <- renderPlot({
    s <- sim()
    n <- if (is.na(s$months)) nrow(s$bands) else min(s$months + 24, nrow(s$bands))
    s$bands <- s$bands[1:n, , drop = FALSE]
    s$paths <- s$paths[1:n, , drop = FALSE]
    t <- (1:n) / 12
    bands <- data.frame(t = t, lo = s$bands[, 1], mid = s$bands[, 2], hi = s$bands[, 3])
    paths <- data.frame(t = rep(t, ncol(s$paths)),
                        v = as.vector(s$paths),
                        id = rep(1:ncol(s$paths), each = n))
    p <- ggplot() +
      geom_line(data = paths, aes(t, v, group = id),
                colour = col_olive, alpha = 0.12, linewidth = 0.35) +
      geom_ribbon(data = bands, aes(t, ymin = lo, ymax = hi),
                  fill = col_sage, alpha = 0.25) +
      geom_line(data = bands, aes(t, mid), colour = col_forest, linewidth = 1.3) +
      geom_hline(yintercept = goal(), linetype = "dashed", colour = col_goal, linewidth = 0.6) +
      annotate("text", x = 0.3, y = goal(), label = "Your goal",
               vjust = -0.6, hjust = 0, colour = col_goal, size = 3.6, fontface = "bold") +
      scale_y_continuous(labels = function(x) paste0("$", formatC(x / 1000, format = "d", big.mark = ","), "k")) +
      labs(x = "Years from now", y = NULL,
           caption = "Shaded: middle 80% of futures (10th to 90th percentile).\nDark line: typical path. Faint lines: single futures.") +
      theme_minimal(base_size = 11) +
      theme(plot.background  = element_rect(fill = "#FFFCF5", colour = NA),
            panel.grid.minor = element_blank(),
            panel.grid.major.x = element_blank(),
            panel.grid.major.y = element_line(colour = "#EDE3CC"),
            axis.text  = element_text(colour = "#6B6656"),
            axis.title = element_text(colour = "#6B6656"),
            plot.caption = element_text(colour = "#6B6656", hjust = 0, size = 9),
            plot.margin = margin(10, 12, 6, 6))
    m <- s$months
    if (!is.na(m)) p <- p + geom_vline(xintercept = m / 12, colour = col_olive, linetype = "dotted", linewidth = 0.7)
    p
  }, res = 96)
  
  output$cost <- renderUI({
    down <- as.numeric(input$down)
    rate <- as.numeric(input$rate)
    loan <- input$price - down_amt()
    pi_pay <- mortgage_payment(loan, rate)          # principal + interest
    tax    <- input$price * 0.0119 / 12             # MI property tax, 1.19% a year [data: Tax Foundation, 2024, Table 2]
    ins    <- 2195 / 12                             # MI home insurance, $2,195 a year [estimate: MoneyGeek 2026]
    # mortgage insurance: only when the down payment is under 20%
    # FHA annual MIP 0.55% a year [data: HUD Mortgagee Letter 2023-05, effective Mar 20 2023]
    # PMI 0.75% a year [choice, inside the 0.30%-1.50% range in the FHFA report]
    # FHA upfront MIP (one-time, added to the loan) is NOT in the payment; the ? text says so
    mi_rate <- if (down >= 0.20) 0 else if (down == 0.035) 0.0055 else 0.0075
    mi     <- loan * mi_rate / 12
    total  <- pi_pay + tax + ins + mi
    pct    <- down * 100
    tags$div(
      tags$div(class = "d-flex align-items-baseline gap-2",
               tags$h1(dollars(total), class = "hero-num"),
               tags$span(class = "text-muted", "/ month")),
      tags$small(class = "text-muted", "Estimated total monthly payment"),
      tags$p(class = "section-label", "Each month"),
      tags$div(
        cost_row("Principal + interest", dollars(pi_pay),
                 "What you pay the bank each month for the loan itself."),
        cost_row("Property tax", dollars(tax),
                 "Michigan average: 1.19% of the home price per year, divided by 12 (Tax Foundation, 2024 data). Your city or township can be higher or lower."),
        cost_row("Home insurance", dollars(ins),
                 "Estimate: Michigan average of about $2,195 per year, divided by 12 (MoneyGeek, 2026). Lenders require home insurance."),
        if (mi > 0) cost_row("Mortgage insurance", dollars(mi),
                             if (down == 0.035)
                               "FHA loans charge a yearly mortgage insurance premium (MIP) of 0.55% of the loan, paid monthly (HUD, effective March 20, 2023). FHA also charges a one-time upfront MIP of 1.75% that is usually added to the loan. That one-time fee is not included here."
                             else
                               "PMI: extra insurance when you put down less than 20%. We use 0.75% of the loan per year. Real PMI runs from about 0.30% to 1.50% depending on your credit score and down payment (FHFA).")
      ),
      tags$p(class = "section-label", "Your loan"),
      tags$div(
        cost_row("Home price", dollars(input$price)),
        cost_row(paste0("Down payment (", pct, "%)"), dollars(down_amt())),
        cost_row("Loan amount", dollars(loan),
                 "Home price minus your down payment. This is what you borrow."),
        cost_row("Interest rate", paste0(rate * 100, "%"),
                 "30-year fixed. 7.11% is the Freddie Mac average, Nov 12 2026."),
        cost_row("Loan length", "30 years")
      ),
      tags$p(class = "mt-3 small text-muted mb-0",
             "Tax and insurance are usually paid monthly with your mortgage (escrow). Not included: utilities, HOA fees, maintenance.")
    )
  })
}

shinyApp(ui, server)