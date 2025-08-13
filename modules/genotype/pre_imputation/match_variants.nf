/* 
Step 2
Match the information about the variants between the new data and the reference model using a custom script in CASTom-iGEx.
The script produces harmonized variant information files Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr... 
and a file with the overall match statistics example_match_stats.txt, which contains variant filtering details for all chromosomes.
*/
process MATCH_VARIANTS {
    tag "${cohort_name} match variants"
    //publishDir "${data_path_prefix}/matched", mode: 'copy'

    input:
        path data_path_prefix
        val dataset_name
        val var_info_file_prefix  // Path to the reference variant annotation files: ${path_to_figshare}/GTEx/genotype_info/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_
        val cohort_name           // Name of the cohort, e.g., "example"  
        val alt_frq_col           // Column name for alternative allele frequency in the reference variant annotation file
        val alt_frq_diff          // Threshold for alternative allele frequency difference
        path script_path          // path to match_genotype_variants.R

    output:
        // Harmonized variant info file
        path ("${data_path_prefix}/matched/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_${cohort_name}_*"), emit: harmonized_info
        path ("${data_path_prefix}/matched/${cohort_name}_match_stats.txt"), emit: match_stats
    
    script:
        """
        mkdir -p "${data_path_prefix}/matched"

        module load palma/2023b GCC/13.2.0 R/4.4.1
        
        Rscript ${script_path} \\
            --varInfoFile ${var_info_file_prefix}/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_   \\
            --aFreqFile ${data_path_prefix}/freq/exampleDataset_ \\
            --cohortName ${cohort_name} \\
            --altFrqColumn ${alt_frq_col} \\
            --altFrqDiff ${alt_frq_diff} \\
            --outInfoFold ${data_path_prefix}/matched/
        
        """
}