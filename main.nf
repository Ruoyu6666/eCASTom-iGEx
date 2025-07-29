#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Pipeline parameters
params.input_gen = null
params.output_dir = "results"
params.reference_panel = null
parameters.imputation_type = "genotype"
params.imputation_method = "priler"
#! params.preprocessing_config = "config/preprocessing.json"
params.chunk_size = 10000
#! params.help = false




workflow{
    
}