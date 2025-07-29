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