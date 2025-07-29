#! Convert .gen input to PLINK binary format (.bed/.bim/.fam) using the .sample file
process GEN_TO_BED {
    tag "chr${chr}"
    input:
        val chr
        path gen_file           // .gen file for that chromosome
        path sample_file        // matching .sample file

    output:
        tuple val(chr), path("exampleDataset_chr${chr}.bed"), path("exampleDataset_chr${chr}.bim"), path("exampleDataset_chr${chr}.fam")

    script:
        """
        plink --gen ${gen_file} \\
              --sample ${sample_file} \\
              --make-bed \\
              --out exampleDataset_chr${chr}
        """
}



#! Summarizing the information about the variants in the example dataset, including alternative allele frequencies
process SUMMARIZE_VARIANTS {
    tag "chr${chr}"
    input:
        val chr
        path bfile_prefix  // Prefix path to .bed/.bim/.fam (no file extension)

    output:
        path "exampleDataset_chr${chr}.afreq"

    script:
        """
        plink2 \\
            --bfile ${bfile_prefix} \\
            --chr ${chr} \\
            --freq cols=+pos \\
            --out exampleDataset_chr${chr}
        """
}
#! This command produces .afreq files per each chromosome.



#! Match the information about the variants between the new data and the reference model using a custom script
process MATCH_GENOTYPE_VARIANTS {
    tag "chr${chr}"
    input:
        val chr
        path freq_file         // exampleDataset_chr${chr}.frq
        path var_info_file     // reference variant info file
        val cohort_name
        val alt_frq_col
        val alt_frq_diff
        path out_dir
        path script_path       // path to match_genotype_variants.R

    output:
        path "Genotype_VariantsInfo_matched_*_chr${chr}"   // harmonized variant info
        // path "${cohort_name}_match_stats.txt" optional     // only emitted once (e.g. chr1)

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



process FILTTER_GENOTYPE_VARIANTS {
    tag "chr${chr}"
    input:
        val chr
        path bfile_prefix
        path harmonized_info      // Genotype_VariantsInfo_matched_..._chr${chr}
        path output_dir

    output:
        path "${output_dir}/exampleDataset_filtered_ref_alt_chr${chr}.raw"

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


