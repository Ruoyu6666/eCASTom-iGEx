# Use a base image with R pre-installed
FROM rocker/r-ver:4.3.1

# Install plink2
RUN apt-get update && apt-get install -y wget \
    && wget https://s3.amazonaws.com/plink2-assets/alpha6/plink2_linux_i686_20250707.zip \
    && unzip plink2_linux_i686_20250707.zip -d /usr/local/bin/ \
    && rm plink2_linux_i686_20250707.zip

# Set the working directory
WORKDIR /app

# Copy the custom R script for installing packages into the container
COPY /src/install_requirements.R .

# Execute the custom R script to install the necessary packages
RUN Rscript install_requirements.R

# Optional: Copy the rest of your Nextflow pipeline files
COPY . /app