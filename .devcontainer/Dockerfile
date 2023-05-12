# Pre-built Dev Container Image for R. 
# More info: https://github.com/rocker-org/devcontainer-images/pkgs/container/devcontainer%2Ftidyverse
# Available R version: 4, 4.1, 4.0
ARG VARIANT="4"
FROM ghcr.io/rocker-org/devcontainer/tidyverse:${VARIANT}

# Install 
RUN apt-get update && \
    apt-get install -y ffmpeg imagemagick
  
# Install R package dependencies
COPY DESCRIPTION /tmp/DESCRIPTION
RUN Rscript -e "devtools::install_deps('/tmp', upgrade = FALSE)"

COPY .rstudio/rstudio-prefs.json /etc/rstudio/rstudio-prefs.json
COPY .rstudio/rsession.conf /etc/rstudio/rsession.conf