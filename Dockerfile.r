# Dockerfile.r
FROM rocker/r-ver:4.4.1

# Install system dependencies including Python and compression libraries
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    gzip \
    zlib1g-dev \
    pkg-config \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Set up Python environment
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Python packages
RUN pip3 install argparse simplejson

# Install required R packages
COPY /src/install_requirements.R /tmp/install_requirements.R

# Execute the custom R script to install the necessary packages
RUN Rscript /tmp/install_requirements.R

# Install data.table (now it will detect zlib headers)
RUN R -e "install.packages('data.table', repos='https://cloud.r-project.org/', configure.args='--enable-zlib')"

# Test data.table compression
RUN R -e "library(data.table); dt <- data.table(x=1:10); fwrite(dt, '/tmp/test.gz', compress='gzip'); cat('data.table compression test passed\n')"

# Set the working directory
WORKDIR /work