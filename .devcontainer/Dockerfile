# Pre-built Dev Container Image for R. 
# More info: https://github.com/rocker-org/devcontainer-images/pkgs/container/devcontainer%2Ftidyverse
# Available R version: 4, 4.1, 4.0
ARG VARIANT="4"
FROM ghcr.io/rocker-org/devcontainer/tidyverse:${VARIANT}

RUN install2.r --error --skipinstalled -n -1 \
      flexdashboard \
      flipbookr \
      fs \
      gganimate \
      gifski \
      here \
      leaflet \
      markdown \
      plotly \
      shiny \
      statebins \
      xaringanthemer
    && rm -rf /tmp/downloaded_packages
