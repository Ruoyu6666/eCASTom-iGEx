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
Match the information about the variants between the new data and the reference model using a custom script
*/
process MATCH_VARIANTS {
    tag "chr${chr}"
    input:
        val chr
        path path_data         // Path to the data directory
        path freq_file         // ${path_data}/freq/exampleDataset_chr${chr}.afreq
        path var_info_file     // Genotype_VariantsInfo_matched_*_chr${chr}.txt
        val cohort_name
        val alt_frq_col
        val alt_frq_diff
        path out_dir
        path script_path       // path to match_genotype_variants.R

    output:
        path "Genotype_VariantsInfo_matched_*_example_chr${chr}"   // harmonized variant info
        path "${cohort_name}_match_stats.txt" optional     // only emitted once (e.g. chr1)

    script:
        """
        Rscript ${script_path} \\
            --varInfoFile ${var_info_file} \\
            --aFreqFile ${freq_file.baseName} \\
            --cohortName ${cohort_name} \\
            --altFrqColumn ${alt_frq_col} \\
            --altFrqDiff ${alt_frq_diff} \\
            --outInfoFold ${out_dir}
        """
}

/* Step 3
Harmonized variant information files are used to filter the genetic data accordingly using PLINK
*/
process FILTER_REF_ALT {
    tag "chr${chr}"
    input:
        val chr
        path bfile_prefix
        path harmonized_info      // Genotype_VariantsInfo_matched_..._example_chr${chr}
        path output_dir
    output:
        path "${output_dir}/exampleDataset_filtered_ref_alt_chr${chr}.traw"

    script:
        """
        cut -f 3 ${var_info_file} > snps_chr${chr}.extract

        plink2 \\
            --bfile ${bfile_prefix} \\
            --chr ${chr} \\
            --extract snps_chr${chr}.extract \\
            --ref-allele force ${var_info_file} 6 3 \\
            --export A \\
            --out exampleDataset_filtered_ref_alt_chr${chr}
        """
}


