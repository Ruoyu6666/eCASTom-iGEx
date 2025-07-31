/*
Step 1
Calculate allele frequencies for the variants in the .bgen files using PLINK2.
The outputs are .afrq files for each chromosome with variant frequencies.
*/
process SUMMARIZE_FREQ {
    tag "chr${chr}"
    
    input:
        val chr
        val dataset_name    // Name of the dataset, e.g., "exampleDataset"
        path path_data      // Path to exampleDataset.bed/.bim/.fam files
    
    output:
        path "${path_data}/freq/${dataset_name}_chr${chr}.afreq", emit: freq_file
    
    script:
        """
        mkdir -p "${path_data}/freq/"

        plink2 \\
            --bfile "${path_data}/${dataset_name}" \\
            --chr ${chr} \\
            --freq cols=+pos \\
            --out "${path_data}/freq/${dataset_name}_chr${chr}"
        """
}


/* 
Step 2
Match the information about the variants between the new data and the reference model using a custom script in CASTom-iGEx.
The script produces harmonized variant information files Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr... 
and a file with the overall match statistics example_match_stats.txt, which contains variant filtering details for all chromosomes.
*/
process MATCH_VARIANTS {
    tag "$cohort_name"

    input:
        path path_data
        val dataset_name
        path var_info_file_prefix  // Path to the reference variant annotation files: ${path_to_figshare}/GTEx/genotype_info/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_
        val cohort_name            // Name of the cohort, e.g., "example"  
        val alt_frq_col            // Column name for alternative allele frequency in the reference variant annotation file
        val alt_frq_diff           // Threshold for alternative allele frequency difference
        path script_path           // path to match_genotype_variants.R

    output:
        // Harmonized variant info file
        path "${path_data}/matched/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_${cohortName}_chr*.txt", emit: harmonized_info
        path "${path_data}/matched/${cohort_name}_match_stats.txt", emit: match_stats
    script:
        """
        mkdir -p "${path_data}/matched"

        Rscript ${script_path} \\
            --varInfoFile ${var_info_file_prefix}   \\
            --aFreqFile ${path_data}/freq/exampleDataset_ \\
            --cohortName ${cohort_name} \\
            --altFrqColumn ${alt_frq_col} \\
            --altFrqDiff ${alt_frq_diff} \\
            --outInfoFold ${path_data}/matched/
        """
}


/* 
Step 3
Harmonized variant information files are used to filter the genetic data accordingly using PLINK
*/
process FILTER_REF_ALT {
    tag "chr${chr}"

    input:
        val chr
        path path_data        
        // bfile_prefix: Prefix path to the .bed/.bim/.fam files
        path harmonized_info  // path_data/matched/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr${chr}
    output:
        path "${path_data}/filtered/exampleDataset_filtered_ref_alt_chr${chr}.traw"

    script:
        """
        mkdir -p "${path_data}/filtered"

        cut -f 3 ${harmonized_info} > snps_chr${chr}.extract

        plink2 \\
            --bfile "${path_data}/bgen/exampleDataset" \\
            --chr ${chr} \\
            --extract snps_chr${chr}.extract \\
            --ref-allele force ${var_info_file} 6 3 \\
            --export A \\
            --out exampleDataset_filtered_ref_alt_chr${chr}
        """
}


