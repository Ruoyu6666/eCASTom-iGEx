# Processing pipeline for genotype imputation with Priler
Based on https://github.com/zillerlab/CASTom-iGEx/wiki/Processing-genetic-data-to-work-with-CASTom%E2%80%90iGEx

## Preparation
First time
```bash
mkdir -p ~/R/library
export R_LIBS_USER=" ~/R-4.2.2/library"
```

Install plink
```bash
mkdir -p ~/tools
cd -p ~/tools
```

```bash
wget https://s3.amazonaws.com/plink2-assets/plink2_linux_avx2_20250707.zip
unzip plink2_linux_avx2_20250707.zip
```
```bash
mkdir -p ~/bin
cd -p ~/bin
ln -s ~/tools/plink2 plink2
```

Clean the environment at the beginning:
```bash
module --force purge
```

load
```bash
module load palma/2023b GCC/13.2.0 R/4.4.1
```

First time install requirements with custom script
```bash
Rscript ${path_to_castom_folder}/install_requirements.R 
```



Search for the specified software and give you instructions how to load it into your environment.
```bash
module spider nextflow
```

Before the "Nextflow/24.04.2" module is available to load, load palma/2024a
```bash
module load palma/2024a Nextflow/24.04.2
```

......


```bash
salloc -c $N_cpus --mem-per-cpu $memory_per_cpu -p normal -t 02:00:00
```




```bash
Rscript /home/r/rguo/scripts/CASTom-iGEx/Software/model_prediction/matchGenotypeModel.R \
  --varInfoFile "/scratch/tmp/rguo/PRILER_TRAINED_MODELS_2023/GTEx/genotype_info/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_" \
  --aFreqFile "/scratch/tmp/rguo/castom-example/exampleDataset_" \
  --cohortName example \
  --altFrqColumn EXP_FREQ_A1_GTEx \
  --altFrqDiff 0.15 \
  --outInfoFold "/scratch/tmp/rguo/castom-example/"
```

```bash
for c in {1..22}; do 
  plink2 \
    --bfile "${path_to_data}/exampleDataset" \
    --extract <(cut -f 3 "${path_to_data}/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr${c}.txt") \
    --ref-allele force "${path_to_data}/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr${c}.txt" 6 3 \
    --export Av \
    --out "${path_to_data}/exampleDataset_filtered_ref_alt_chr${c}"
done
```



```bash
Rscript /home/r/rguo/scripts/CASTom-iGEx/Software/model_prediction/formatGenotypeDosage.R \
  --trawFile "${path_to_data}/exampleDataset_filtered_ref_alt_" \
  --sampleFile "${path_to_data}/exampleDataset.fam" \
  --sampleNameColumn 2 \
  --dosageThresh 0.1 \
  --outDosageFold "${path_to_data}"
```


```bash
Rscript /home/r/rguo/scripts/CASTom-iGEx/Software/model_prediction/PriLer_predictGeneExp_run.R \
  --genoDat_file "${path_to_data}/exampleDataset_filtered_ref_alt_" \
  --covDat_file "${path_to_data}/example_sample_cov.txt" \
  --outFold "${path_to_data}/" \
  --outTrain_fold "/scratch/tmp/rguo/PRILER_TRAINED_MODELS_2023/GTEx/tissues/Whole_Blood/" \
  --InfoFold "/scratch/tmp/rguo/PRILER_TRAINED_MODELS_2023/GTEx/tissues/Whole_Blood/"
```


## Run on example dataset with nextflow
```bash
nextflow run main.nf -profile docker \
  --gen_dir "/gen/dir" \
  --sample_file "/data/exampleDataset.sample" \
  --data "/data" \
  --ref_info "/reference/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_" \
  --script_dir "/Software/model_prediction" \
  --model_dir "/GTEx" \
  --results_dir "/results" \
  --tissue "Whole_Blood"
```
```bash
module load palma/2022b Java/17.0.6
nextflow run main.nf
```

