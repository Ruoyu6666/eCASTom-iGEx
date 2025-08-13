#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// Include the processes from the modules
include { SUMMARIZE_FREQ } from './modules/genotype/pre_imputation/summarize_freq.nf'
include { MATCH_VARIANTS } from './modules/genotype/pre_imputation/match_variants.nf'
include { FILTER_REF_ALT } from './modules/genotype/pre_imputation/filter_ref_alt.nf'
include { FORMAT_DOSAGE } from './modules/genotype/pre_imputation/format_dosage.nf'
include { IMPUTE_GENOTYPE_PRILER } from './modules/genotype/imputation/priler.nf'




// Define workflow
workflow {
    // Channel for chromosomes 1 to 22
    chr = Channel.from(22)
    /*
    channel_freq = SUMMARIZE_FREQ(
        chr,
        params.dataset_name,
        params.data_path_prefix
    ).freq_file
    
    
    // Step 2: Match variants with reference model
    channel_match = MATCH_VARIANTS(
        params.data_path_prefix,
        params.dataset_name,
        params.var_info_file_prefix,
        params.cohort_name,
        params.alt_frq_col,
        params.alt_frq_diff,
        params.script_match_variants
    )

    channel_harmonized = chr.combine(MATCH_VARIANTS.out.harmonized_info.flatten())
        .filter { chr, file -> 
            file.getName().contains("chr${chr}.txt") 
        }
    
    // Step 3: Filter genetic data using harmonized variant information.
    channel_filter = FILTER_REF_ALT(
        chr,
        params.data_path_prefix,
        params.dataset_name,
        "${params.data_path_prefix}/matched"
        // channel_match.harmonized_info
    ).traw_file
    

    // Step 4: Format dosage files for PRILER
    FORMAT_DOSAGE(
        params.data_path_prefix,
        params.dataset_name,
       "${params.data_path_prefix}/${params.dataset_name}.fam",
        params.script_format_dosage,
        params.dosage_thresh
    )
    
    */
    // Step 5: Impute genotype using PRILER
    IMPUTE_GENOTYPE_PRILER(
        params.data_path_prefix,
        params.dataset_name,
        params.tissue,
        params.model_path_prefix,
        params.covariates_file,
        params.script_genotye_priler,
    )



    //FORMAT_DOSAGE.out.formatted_dosage_file.view { "✨ Formatted dosage for chromosome ${chr}" }
}
