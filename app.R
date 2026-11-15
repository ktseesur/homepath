library(shiny)
library(bslib)
library(ggplot2)
source("functions.R")
params <- readRDS("data/mu_sigma.rds")

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
  tags$div(class = "d-flex justify-content-between align-items-center py-2 border-bottom",
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

ui <- page_sidebar(
  title = "HomePath",
  theme = bs_theme(
    primary = "#2E5A3C", bg = "#FAF6EF", fg = "#1F2A22",
    base_font = font_google("Inter"),
    "input-bg" = "#FFFFFF", "border-radius" = "0.6rem"
  ),
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
    tags$div(class = "d-flex align-items-center gap-1",
             checkboxInput("dpa", "Michigan down payment help", value = FALSE),
             help_icon("MI 10K DPA",
                       "Michigan's MSHDA program gives up to $10,000 toward your down payment. You must meet income and price limits and use a participating lender.")
    ),
    tags$div(
      label_row("Money in index fund", "Savings vs index fund",
                "Savings account: safe, grows slowly. Index fund (S&P 500): grows more on average but can drop. 1-2 years: savings. 5+ years: index fund can help."),
      sliderInput("w", NULL, min = 0, max = 100, value = 60, post = "%", width = "100%")
    )
  ),
  layout_columns(
    col_widths = c(8, 4),
    card(card_header("When can you buy?"), uiOutput("result"),
         plotOutput("fan", height = "320px")),
    card(card_header("Your monthly payment"), uiOutput("cost"))
  ),
  tags$p(class = "text-muted small text-center mt-2",
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
                   params$mu, params$sigma)
  })
  
  output$result <- renderUI({
    if (input$start >= goal()) {
      return(tags$div(
        tags$h1("You're ready now!", class = "display-5 fw-bold text-primary"),
        tags$p(paste0("Your savings already cover the ", dollars(goal()), " you need."))
      ))
    }
    m <- sim()$months
    if (is.na(m)) {
      return(tags$div(
        tags$h2("Not within 15 years"),
        tags$p("Try saving more, a smaller down payment, or a lower home price.")
      ))
    }
    when <- seq(Sys.Date(), by = "month", length.out = m + 1)[m + 1]
    pct  <- round(100 * sim()$chance[m])
    b    <- sim()$bands[m, ]
    box  <- function(lbl, val, cls) tags$div(class = "text-center px-3",
                                             tags$small(lbl), tags$h4(dollars(val), class = paste("fw-bold mb-0", cls)))
    tags$div(
      tags$p("You can likely buy in", class = "mb-0"),
      tags$div(class = "d-flex align-items-end gap-4",
               tags$h1(format(when, "%B %Y"), class = "display-5 fw-bold text-primary mb-0"),
               tags$div(
                 tags$h2(paste0(pct, "%"), class = "fw-bold mb-0"),
                 tags$small("chance by then")
               )
      ),
      tags$p(class = "mt-2", paste0(m %/% 12, " yr ", m %% 12, " mo. You need ",
                                    dollars(goal()), ". ", pct, "% of 2,000 simulated futures reach it by then.")),
      tags$p(class = "mb-1 fw-semibold", paste0("What you might have by ", format(when, "%B %Y"), ":")),
      tags$div(class = "d-flex",
               box("Unlucky (10%)", b[1], "text-danger"),
               box("Typical (50%)", b[2], "text-primary"),
               box("Lucky (90%)",   b[3], "text-success"))
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
                colour = "#2E5A3C", alpha = 0.12, linewidth = 0.4) +
      geom_ribbon(data = bands, aes(t, ymin = lo, ymax = hi),
                  fill = "#2E5A3C", alpha = 0.18) +
      geom_line(data = bands, aes(t, mid), colour = "#2E5A3C", linewidth = 1.2) +
      geom_hline(yintercept = goal(), linetype = "dashed", colour = "#C2410C") +
      annotate("text", x = 0.3, y = goal(), label = "Your goal",
               vjust = -0.6, hjust = 0, colour = "#C2410C", size = 4) +
      scale_y_continuous(labels = function(x) paste0("$", formatC(x / 1000, format = "d", big.mark = ","), "k")) +
      labs(x = "Years from now", y = NULL,
           caption = "Shaded: middle 80% of futures (10th to 90th percentile).\nDark line: typical path. Faint lines: single futures.") +
      theme_minimal(base_size = 13) +
      theme(plot.background = element_rect(fill = "#FFFFFF", colour = NA),
            panel.grid.minor = element_blank(),
            plot.caption = element_text(colour = "grey40", hjust = 0))
    m <- s$months
    if (!is.na(m)) p <- p + geom_vline(xintercept = m / 12, colour = "#2E5A3C", linetype = "dotted")
    p
  })
  
  output$cost <- renderUI({
    loan <- input$price - down_amt()
    pay  <- mortgage_payment(loan)
    pct  <- as.numeric(input$down) * 100
    tags$div(
      tags$div(class = "d-flex align-items-baseline gap-2",
               tags$h1(dollars(pay), class = "display-5 fw-bold text-primary mb-0"),
               tags$span("/ month")),
      tags$small(class = "text-muted", "Mortgage principal + interest"),
      tags$div(class = "mt-3",
               cost_row("Home price", dollars(input$price)),
               cost_row(paste0("Down payment (", pct, "%)"), dollars(down_amt())),
               cost_row("Loan amount", dollars(loan),
                        "Home price minus your down payment. This is what you borrow."),
               cost_row("Interest rate", "7.11%",
                        "30-year fixed average from Freddie Mac, Nov 12 2026."),
               cost_row("Loan length", "30 years")
      ),
      tags$div(class = "d-flex align-items-center gap-1 mt-3 small text-muted",
               "Not yet included: property tax, insurance, PMI",
               help_icon("Coming next",
                         "Your real monthly cost also includes Michigan property tax, home insurance, and PMI if you put down less than 20%. We're adding these with sourced data."))
    )
  })
}

shinyApp(ui, server)