FROM rocker/verse:4.3.0
LABEL version=12

# Install 
RUN apt-get update && \
    apt-get install -y ffmpeg imagemagick
  
# Install gifski
RUN wget -O /tmp/gifski-1.11.0.zip https://gif.ski/gifski-1.11.0.zip && \
    unzip -d /tmp/gifski-1.11.0 /tmp/gifski-1.11.0.zip && \
    sudo apt install /tmp/gifski-1.11.0/linux/gifski_1.11.0_amd64.deb

# Install R package dependencies
COPY ./DESCRIPTION /tmp/DESCRIPTION
RUN Rscript -e "devtools::install_deps('/tmp', upgrade = FALSE)"

COPY ./.rstudio/rstudio-prefs.json /etc/rstudio/rstudio-prefs.json
COPY .rstudio/rsession.conf /etc/rstudio/rsession.conf

