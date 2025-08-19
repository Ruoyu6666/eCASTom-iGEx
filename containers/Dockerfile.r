# Dockerfile.r
FROM rocker/r-ver:4.4.1

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Python packages
RUN pip3 install argparse simplejson

# Install required R packages
COPY /src/install_requirements.R /tmp/install_requirements.R

# Execute the custom R script to install the necessary packages
RUN Rscript /tmp/install_requirements.R

WORKDIR /work