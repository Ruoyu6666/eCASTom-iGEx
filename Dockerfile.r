# Dockerfile.r
FROM rocker/r-ver:4.4.1

# Install essential system dependencies 
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    gzip \
    zlib1g-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install blas, lapack, and openblas
RUN apt-get update && apt-get install -y \
    libblas-dev \
    liblapack-dev \
    libopenblas-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python and pip. Use gcc-12 and g++-12 for compatibility with R packages that require C++
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    g++-12 \
    gcc-12 \
    libstdc++-12-dev \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for missing FlexiBLAS library
RUN ln -sf /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 /usr/lib/x86_64-linux-gnu/libflexiblas.so.3 || \
    ln -sf /usr/lib/x86_64-linux-gnu/libblas.so.3 /usr/lib/x86_64-linux-gnu/libflexiblas.so.3

# Set alternatives for gcc and g++
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100

# Set environment variables to use gcc-12 and g++-12
ENV CC=/usr/bin/gcc-12
ENV CXX=/usr/bin/g++-12

# Set up Python environment
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Python packages
RUN pip3 install argparse simplejson

# Install required R packages
COPY /src/install_requirements.R /tmp/install_requirements.R
RUN Rscript /tmp/install_requirements.R
RUN R -e "install.packages('data.table', repos='https://cloud.r-project.org/', configure.args='--enable-zlib')"
RUN R -e "install.packages(c('Matrix', 'bigmemory'), repos='https://cloud.r-project.org/', type='source')"

# Set the working directory
WORKDIR /work