knitr::opts_chunk$set(
  echo = TRUE,
  collapse = TRUE,
  comment = "#>",
  fig.path = "img/",
  fig.retina = 2,
  fig.width = 6,
  fig.asp = 9 / 16,
  fig.pos = "t",
  fig.align = "center",
  out.width = "100%",
  dev.args = list(png = list(type = "cairo-png")),
  optipng = "-o1 -quiet"
  # dpi = if (knitr::is_latex_output()) 72 else 150,
  # dev = "svg",
)
knitr::opts_knit$set(
  # upload.fun = imgur_upload_v2, 
  base.url = NULL
)
set.seed(1234)