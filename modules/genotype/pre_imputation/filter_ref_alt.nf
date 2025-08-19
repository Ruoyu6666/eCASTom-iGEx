/* 
Step 3
Harmonized variant information files are used to filter the genetic data accordingly using PLINK
*/

process FILTER_REF_ALT {
    label 'plink'
    container 'my_plink.sif'
    tag "chr${chr}"

    input:
        val chr
        path data_path_prefix
        val dataset_name      // exampleDataset
        path harmonized_info  // data_path_prefix/matched/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr${chr}
        val dummy_trigger // Dummy trigger to ensure the process runs after MATCH_VARIANTS
    
    output:
        path ("${data_path_prefix}/filtered/${dataset_name}_filtered_ref_alt_chr${chr}.*"), emit: traw_file

    script:
        """
        mkdir -p "${data_path_prefix}/filtered"

        plink2 \\
            --bfile "${data_path_prefix}/${dataset_name}" \\
            --chr ${chr} \\
            --extract <(cut -f 3 "${harmonized_info}/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr${chr}.txt") \\
            --ref-allele force "${harmonized_info}/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr${chr}.txt" 6 3 \\
            --export Av \\
            --out "${data_path_prefix}/filtered/exampleDataset_filtered_ref_alt_chr${chr}"
        """
}