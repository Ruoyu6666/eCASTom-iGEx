# Processing pipeline for genotype imputation with Priler (run WITHOUT Apptainer)
This repository provides a processing pipeline for genotype imputation using PriLer, managed with Nextflow.
It is based on the [CASTom-iGEx genetic data processing guide](https://github.com/zillerlab/CASTom-iGEx/wiki/Processing-genetic-data-to-work-with-CASTom%E2%80%90iGEx)

## Preparation

### - Install R packages
When working on Palma, load module R/4.4.1 and the required dependencies:
```bash
module --force purge  # Clean the environment on HPC at the beginning
module load palma/2023b GCC/13.2.0 R/4.4.1
```

Required R packages for the complete pipeline can be installed with an R custom script:
```bash
mkdir -p ~/R/library
export R_LIBS_USER=" ~/R/library"
Rscript ~/scripts/eCASTom/src/install_requirements.R
```
**Note**

When run further R script add `.libPaths("~/R/library")` at the top of the script to create a search path for R.



### - Install plink2
```bash
mkdir -p ~/tools
cd ~/tools
# The following version is outdated. Check the latest version on https://www.cog-genomics.org/plink/2.0/
wget https://s3.amazonaws.com/plink2-assets/plink2_linux_avx2_20250707.zip
unzip plink2_linux_avx2_20250707.zip

mkdir -p ~/bin
mv plink2 ~/bin
chmod +x ~/bin/plink2
rm plink2_linux_avx2_20250707.zip
```



### - Install Nextflow2
Ensure that Nextflow is installed. Load dependencies necessary to install & run Nextflow
```bash
module load palma/2022b Java/17.0.6
```

Install Nextflow by following the [installation guide](https://www.nextflow.io/docs/latest/install.html). In the end, make sure to move Nextflow into an executable path. 
```bash
mv nextflow ~/bin
```



## Run the pipeline on example dataset with Nextflow
Load dependencies necessary to run Nextflow
```bash
module load palma/2022b Java/17.0.6
```
Start a job:
```bash
salloc -c $N_cpus --mem-per-cpu $memory_per_cpu -p normal -t 06:00:00
```
Run the complete pipeline with nextflow command:
```bash
nextflow run main.nf
```

