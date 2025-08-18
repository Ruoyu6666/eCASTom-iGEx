# Use a base image with R pre-installed
FROM rocker/r-base:4.4.1

# Install
RUN apt-get update && apt-get install -y \
    wget unzip \
    && rm -rf /var/lib/apt/lists/*

    # Install plink2
RUN wget https://s3.amazonaws.com/plink2-assets/alpha6/plink2_linux_i686_20250707.zip \
    && unzip plink2_linux_i686_20250707.zip \
    && mv plink2 /usr/local/bin/ \
    && chmod +x /usr/local/bin/plink2

# Set the working directory
WORKDIR /app

# Copy the custom R script for installing packages into the container
COPY /src/install_requirements.R /tmp/install_requirements.R

# Execute the custom R script to install the necessary packages
RUN Rscript /tmp/install_requirements.R

# Optional: Copy the rest of your Nextflow pipeline files
COPY . /app