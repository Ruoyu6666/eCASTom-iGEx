/* 
Step 0
Convert .gen files to binary format (.bed/.bim/.fam) using the provided .sample file.
The output is a tuple containing the chromosome number and paths to the generated files.
*/
process GEN_TO_BED {
    tag "chr${chr}"         // Split by chromosomes
    input:
        val chr
        path gen_file       // Path to the .gen file for the chromosome
        path sample_file    // Path to the .sample file
        path path_data      // Path to the data directory
    
    output:
        tuple val(chr), path("${path_data}/bgen/exampleDataset_chr${chr}.bed"), \
                        path("${path_data}/bgen/exampleDataset_chr${chr}.bim"), \
                        path("${path_data}/bgen/exampleDataset_chr${chr}.fam")
    script:
        """
        mkdir -p "${path_data}/bgen"

        plink2 --gen ${gen_file} \
               --sample ${sample_file} \
               --make-bed \
               --out ${path_to_data}/bgen/exampleDataset_chr${chr}
        """
}


/* 
Step 1
Summarize the information about the variants in the example dataset including alternative allele frequencies
This command produces .afreq files per each chromosome.
*/
process SUMMARIZE_FREQ {
    tag "chr${chr}"
    input:
        val chr
        path path_data  // Prefix path to .bed/.bim/.fam
    output:
        path "${path_data}/freq/exampleDataset_chr${chr}.afreq"

    script:
        """
        mkdir -p "${path_data}/freq"

        plink2 \\
            --bfile ${path_data} \\
            --chr ${chr} \\
            --freq cols=+pos \\
            --out ${path_data}/freq/exampleDataset_chr${chr}
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
        path path_data             // Path to the data directory
        path var_info_file_prefix  // Path to the reference variant annotation files: ../GTEx/genotype_info/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_
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

/* Step 3
Harmonized variant information files are used to filter the genetic data accordingly using PLINK
*/
process FILTER_REF_ALT {
    tag "chr${chr}"

    input:
        val chr
        path path_data        
        // bfile_prefix: Prefix path to the .bed/.bim/.fam files
        path harmonized_info  // ../matched/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr${chr}
    output:
        path "${path_data}/filtered/exampleDataset_filtered_ref_alt_chr${chr}.traw"

    script:
        """
        mkdir -p "${path_data}/filtered"

        cut -f 3 ${var_info_file} > snps_chr${chr}.extract

        plink2 \\
            --bfile "${path_data}/bgen/exampleDataset" \\
            --chr ${chr} \\
            --extract snps_chr${chr}.extract \\
            --ref-allele force ${var_info_file} 6 3 \\
            --export A \\
            --out exampleDataset_filtered_ref_alt_chr${chr}
        """
}


