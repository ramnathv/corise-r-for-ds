knitr::opts_chunk$set(
  fig.width = 8, 
  fig.height = 6,
  fig.retina = 2,
  dev = 'png',
  out.width = "100%",
  dev.args = list(png = list(type = "cairo-png")),
  optipng = "-o1 -quiet",
  message = FALSE,
  warning = FALSE, 
  comment = "", 
  cache = FALSE
)

# Load packages 
library(flipbookr)
library(tidyverse)
library(palmerpenguins)
library(gganimate)
library(babynames)
library(xaringanExtra)


# Load xaringan extras
# xaringanExtra::use_xaringan_extra(c("tile_view"))
# xaringanExtra::use_scribble()
# xaringanExtra::use_freezeframe()
# xaringanExtra::use_panelset()
# xaringanExtra::style_panelset_tabs(font_family = "inherit")

# Set ggplot2 theme
FILL_COLOR <- "#FAFAFA"
ggplot2::theme_set(
  ggplot2::theme_gray(base_size = 14) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(
        fill = FILL_COLOR, 
        color = FILL_COLOR
      )
    )
)

# Utility functions
chunk_reveal_md <- function(chunk_name, code_comments, left_assign = TRUE, ...) {
  chunk_reveal(
    chunk_name, 
    title = code_comments[1], 
    md = code_comments[-1], 
    display_type = c("code", "output", "md"),
    left_assign = left_assign,
    ...
  )
}
