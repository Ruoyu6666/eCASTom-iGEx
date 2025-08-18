# Dockerfile.r
FROM r-base:4.4.1

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*


# Install required R packages
COPY /src/install_requirements.R /tmp/install_requirements.R

# Execute the custom R script to install the necessary packages
RUN Rscript /tmp/install_requirements.R

WORKDIR /work