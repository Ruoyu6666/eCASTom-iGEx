# Processing pipeline for genotype imputation with Priler (run with Apptainer)
This repository provides a processing pipeline for genotype imputation using PriLer, managed with Nextflow and containerized via Apptainer.
It is based on the [CASTom-iGEx genetic data processing guide](https://github.com/zillerlab/CASTom-iGEx/wiki/Processing-genetic-data-to-work-with-CASTom%E2%80%90iGEx)

## Preparation
When working on Palma, load Nextflow/24.04.2 module and the required dependencies:
```bash
module --force purge  # Clean the environment on HPC at the beginning
module load palma/2024a Nextflow/24.04.2
```
Alternatively (recommended), instead of loading the nextflow module, install Nextflow by following the [installation guide](https://www.nextflow.io/docs/latest/install.html) 

## Build Docker Images
Ensure that Docker is installed and build the images locally:

```bash
docker build -f Dockerfile.plink -t pipeline/castom-plink:1.0 .
docker build -f Dockerfile.r -t pipeline/castom-r:1.0 .
```
On HPC users usually have no root privilege and therefore cannot install Docker. To solve this, one can build the images locally on PC as shown above and then push the images to Docker Hub. Later, pull the images as Apptainer/Singularity files in the HPC environment:
```bash
docker push pipeline/castom-plink:1.0
docker push pipeline/castom-r:1.0
```

## Run the pipeline on example dataset with Nextflow on container (Apptainer)
Ensure that Apptainer and Nextflow are installed. The pipeline uses multiple containers to perform the preprocessing and imputation. These containers can be pulled directly from Docker Hub.
Load required modules on HPC:
```bash 
module load Apptainer/1.2.5           # load Apptainer
module load palma/2022b Java/17.0.6   # load dependencies necessary to install & run Nextflow
```
Pull the Docker images from Docker Hub:
```bash
apptainer pull my_plink.sif docker://pipeline/castom-plink:1.0
apptainer pull my_r.sif docker://pipeline/castom-r:1.0
```
Start a job (at least 24G memory):
```bash
salloc -c $N_cpus --mem-per-cpu $memory_per_cpu -p normal -t 06:00:00
```
Run the complete pipeline with nextflow command:
```bash
nextflow run main.nf -c nextflow.config
```